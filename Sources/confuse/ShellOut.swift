//
//  ShellOut.swift
//
//
//  Created by Mosquito1123 on 27/11/2019.
//

import Foundation
import Dispatch


import Cocoa
 
class CommandRunner: NSObject {
    
    /** 同步执行
     *  command:    shell 命令内容
     *  returns:    命令行执行结果，积压在一起返回
     *
     *  使用示例
        let (res, rev) = CommandRunner.sync(command: "ls -l")
        print(rev)
     */
    static func sync(command: String) -> (Int, String) {
        let utf8Command = "export LANG=en_US.UTF-8\n" + command
        return sync(shellPath: "/bin/bash", arguments: ["-c", utf8Command])
    }
    
    /** 同步执行
     *  shellPath:  命令行启动路径
     *  arguments:  命令行参数
     *  returns:    命令行执行结果，积压在一起返回
     *
     *  使用示例
        let (res, rev) = CommandRunner.sync(shellPath: "/usr/sbin/system_profiler", arguments: ["SPHardwareDataType"])
        print(rev)
     */
    static func sync(shellPath: String, arguments: [String]? = nil) -> (Int, String) {
        let task = Process()
        let pipe = Pipe()
        
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        var home:String
        if #available(OSX 10.12, *) {
            home = FileManager.default.homeDirectoryForCurrentUser.path
        } else {
            // Fallback on earlier versions
            home = URL(fileURLWithPath: NSHomeDirectory()).path
            
        }
        environment = ["LANG": "en_US.UTF-8",
                       "PATH": "$PATH:$HOME/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/sbin:/usr/local/bin",
                       "LC_ALL": "en_US.UTF-8",
                       "HOME": home
        ]
        task.environment = environment
        
        if arguments != nil {
            task.arguments = arguments!
        }
        
        task.launchPath = shellPath
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = String(data: data, encoding: String.Encoding.utf8)!
        
        task.waitUntilExit()
        pipe.fileHandleForReading.closeFile()
        
        return (Int(task.terminationStatus), output)
    }
    
    /** 异步执行
     *  command:    shell 命令内容
     *  output:     每行的输出内容实时回调(主线程回调)
     *  terminate:  命令执行结束状态(主线程回调)
     *
     *  使用示例
        CommandRunner.async(command: "ls -l",
                            output: {[weak self] (str) in
                                self?.appendLog(str: str)
                            },
                            terminate: {[weak self] (code) in
                                self?.appendLog(str: "end \(code)")
                            })
     */
    static func async(command: String,
                      output: ((String) -> Void)? = nil,
                      terminate: ((Int) -> Void)? = nil) {
        let utf8Command = "export LANG=en_US.UTF-8\n" + command
        async(shellPath: "/bin/bash", arguments: ["-c", utf8Command], output:output, terminate:terminate)
    }
    
    /** 异步执行
     *  shellPath:  命令行启动路径
     *  arguments:  命令行参数
     *  output:     每行的输出内容实时回调(主线程回调)
     *  terminate:  命令执行结束状态(主线程回调)
     *
     *  使用示例
        CommandRunner.async(shellPath: "/usr/sbin/system_profiler",
                            arguments: ["SPHardwareDataType"],
                            output: {[weak self] (str) in
                                self?.appendLog(str: str)
                            },
                            terminate: {[weak self] (code) in
                                self?.appendLog(str: "end \(code)")
                            })
     */
    static func async(shellPath: String,
                      arguments: [String]? = nil,
                      output: ((String) -> Void)? = nil,
                      terminate: ((Int) -> Void)? = nil) {
        DispatchQueue.global().async {
            let task = Process()
            let pipe = Pipe()
            let outHandle = pipe.fileHandleForReading
            
            var environment = ProcessInfo.processInfo.environment
            environment["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
            var home:String
            if #available(OSX 10.12, *) {
                home = FileManager.default.homeDirectoryForCurrentUser.path
            } else {
                // Fallback on earlier versions
                home = URL(fileURLWithPath: NSHomeDirectory()).path

            }
            environment = ["LANG": "en_US.UTF-8",
                                "PATH": "$PATH:$HOME/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/sbin:/usr/local/bin",
                                "LC_ALL": "en_US.UTF-8",
                                "HOME": home
            ]
            task.environment = environment
            
            if arguments != nil {
                task.arguments = arguments!
            }
            
            task.launchPath = shellPath
            task.standardOutput = pipe
            
            outHandle.waitForDataInBackgroundAndNotify()
            var obs1 : NSObjectProtocol!
            obs1 = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                                          object: outHandle, queue: nil) {  notification -> Void in
                                                            let data = outHandle.availableData
                                                            if data.count > 0 {
                                                                if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                                                                    DispatchQueue.main.async {
                                                                        output?(str as String)
                                                                    }
                                                                }
                                                                outHandle.waitForDataInBackgroundAndNotify()
                                                            } else {
                                                                if let obs11 = obs1{
                                                                    NotificationCenter.default.removeObserver(obs11)
                                                                    
                                                                };                                                      pipe.fileHandleForReading.closeFile()
                                                            }
            }
            
            var obs2 : NSObjectProtocol!
            obs2 = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
                                                          object: task, queue: nil) { notification -> Void in
                                                            DispatchQueue.main.async {
                                                                terminate?(Int(task.terminationStatus))
                                                            }
                                                            if let obs22 = obs2{
                                                                NotificationCenter.default.removeObserver(obs22)

                                                            }
            }
            
            task.launch()
            task.waitUntilExit()
        }
    }
}

@discardableResult
public func shell(_ launchPath: String, _ arguments: [String] = []) -> (String?, Int32) {
  let task = Process()
//    if #available(OSX 10.13, *) {
//        task.executableURL = URL(fileURLWithPath: launchPath)
//    } else {
//        // Fallback on earlier versions
//    }
    task.launchPath = launchPath
  task.arguments = arguments
//    task.currentDirectoryPath = "/Users/elen/Desktop/chess-shell-ios"
    var home:String
    if #available(OSX 10.12, *) {
        home = FileManager.default.homeDirectoryForCurrentUser.path
    } else {
        // Fallback on earlier versions
        home = URL(fileURLWithPath: NSHomeDirectory()).path

    }
    print(home)
    task.environment = ["LANG": "en_US.UTF-8",
                        "PATH": "$PATH:$HOME/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/sbin:/usr/local/bin",
                        "LC_ALL": "en_US.UTF-8",
                        "HOME": home
    ]
    
  let pipe = Pipe()
  task.standardOutput = pipe
  task.standardError = pipe

  do {
    if #available(OSX 10.13, *) {
        try task.run()
    } else {
        // Fallback on earlier versions
    }
  } catch {
    // handle errors
    print("Error: \(error.localizedDescription)")
  }

  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  let output = String(data: data, encoding: .utf8)

  task.waitUntilExit()
  return (output, task.terminationStatus)
}
// MARK: - API

/**
 *  Run a shell command using Bash
 *
 *  - parameter command: The command to run
 *  - parameter arguments: The arguments to pass to the command
 *  - parameter path: The path to execute the commands at (defaults to current folder)
 *  - parameter outputHandle: Any `FileHandle` that any output (STDOUT) should be redirected to
 *              (at the moment this is only supported on macOS)
 *  - parameter errorHandle: Any `FileHandle` that any error output (STDERR) should be redirected to
 *              (at the moment this is only supported on macOS)
 *
 *  - returns: The output of running the command
 *  - throws: `ShellOutError` in case the command couldn't be performed, or it returned an error
 *
 *  Use this function to "shell out" in a Swift script or command line tool
 *  For example: `shellOut(to: "mkdir", arguments: ["NewFolder"], at: "~/CurrentFolder")`
 */
@discardableResult public func shellOut(to command: String,
                                        arguments: [String] = [],
                                        at path: String = ".",
                                        outputHandle: FileHandle? = nil,
                                        errorHandle: FileHandle? = nil) throws -> String {
    let process = Process()
    let command = "cd \(path.escapingSpaces) && \(command) \(arguments.joined(separator: " "))".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    return try process.launchBash(with: command, outputHandle: outputHandle, errorHandle: errorHandle)
}

/**
 *  Run a series of shell commands using Bash
 *
 *  - parameter commands: The commands to run
 *  - parameter path: The path to execute the commands at (defaults to current folder)
 *  - parameter outputHandle: Any `FileHandle` that any output (STDOUT) should be redirected to
 *              (at the moment this is only supported on macOS)
 *  - parameter errorHandle: Any `FileHandle` that any error output (STDERR) should be redirected to
 *              (at the moment this is only supported on macOS)
 *
 *  - returns: The output of running the command
 *  - throws: `ShellOutError` in case the command couldn't be performed, or it returned an error
 *
 *  Use this function to "shell out" in a Swift script or command line tool
 *  For example: `shellOut(to: ["mkdir NewFolder", "cd NewFolder"], at: "~/CurrentFolder")`
 */
@discardableResult public func shellOut(to commands: [String],
                                        at path: String = ".",
                                        outputHandle: FileHandle? = nil,
                                        errorHandle: FileHandle? = nil) throws -> String {
    let command = commands.joined(separator: " && ")
    return try shellOut(to: command, at: path, outputHandle: outputHandle, errorHandle: errorHandle)
}

/**
 *  Run a pre-defined shell command using Bash
 *
 *  - parameter command: The command to run
 *  - parameter path: The path to execute the commands at (defaults to current folder)
 *  - parameter outputHandle: Any `FileHandle` that any output (STDOUT) should be redirected to
 *  - parameter errorHandle: Any `FileHandle` that any error output (STDERR) should be redirected to
 *
 *  - returns: The output of running the command
 *  - throws: `ShellOutError` in case the command couldn't be performed, or it returned an error
 *
 *  Use this function to "shell out" in a Swift script or command line tool
 *  For example: `shellOut(to: .gitCommit(message: "Commit"), at: "~/CurrentFolder")`
 *
 *  See `ShellOutCommand` for more info.
 */
@discardableResult public func shellOut(to command: ShellOutCommand,
                                        at path: String = ".",
                                        outputHandle: FileHandle? = nil,
                                        errorHandle: FileHandle? = nil) throws -> String {
    return try shellOut(to: command.string, at: path, outputHandle: outputHandle, errorHandle: errorHandle)
}

/// Structure used to pre-define commands for use with ShellOut
public struct ShellOutCommand {
    /// The string that makes up the command that should be run on the command line
    public var string: String

    /// Initialize a value using a string that makes up the underlying command
    public init(string: String) {
        self.string = string
    }
}

/// Git commands
public extension ShellOutCommand {
    /// Initialize a git repository
    static func gitInit() -> ShellOutCommand {
        return ShellOutCommand(string: "git init")
    }

    /// Clone a git repository at a given URL
    static func gitClone(url: URL, to path: String? = nil) -> ShellOutCommand {
        var command = "git clone \(url.absoluteString)"
        path.map { command.append(argument: $0) }
        command.append(" --quiet")

        return ShellOutCommand(string: command)
    }

    /// Create a git commit with a given message (also adds all untracked file to the index)
    static func gitCommit(message: String) -> ShellOutCommand {
        var command = "git add . && git commit -a -m"
        command.append(argument: message)
        command.append(" --quiet")

        return ShellOutCommand(string: command)
    }

    /// Perform a git push
    static func gitPush(remote: String? = nil, branch: String? = nil) -> ShellOutCommand {
        var command = "git push"
        remote.map { command.append(argument: $0) }
        branch.map { command.append(argument: $0) }
        command.append(" --quiet")

        return ShellOutCommand(string: command)
    }

    /// Perform a git pull
    static func gitPull(remote: String? = nil, branch: String? = nil) -> ShellOutCommand {
        var command = "git pull"
        remote.map { command.append(argument: $0) }
        branch.map { command.append(argument: $0) }
        command.append(" --quiet")

        return ShellOutCommand(string: command)
    }

    /// Run a git submodule update
    static func gitSubmoduleUpdate(initializeIfNeeded: Bool = true, recursive: Bool = true) -> ShellOutCommand {
        var command = "git submodule update"

        if initializeIfNeeded {
            command.append(" --init")
        }

        if recursive {
            command.append(" --recursive")
        }

        command.append(" --quiet")
        return ShellOutCommand(string: command)
    }

    /// Checkout a given git branch
    static func gitCheckout(branch: String) -> ShellOutCommand {
        let command = "git checkout".appending(argument: branch)
                                    .appending(" --quiet")

        return ShellOutCommand(string: command)
    }
}

/// File system commands
public extension ShellOutCommand {
    /// Create a folder with a given name
    static func createFolder(named name: String) -> ShellOutCommand {
        let command = "mkdir".appending(argument: name)
        return ShellOutCommand(string: command)
    }

    /// Create a file with a given name and contents (will overwrite any existing file with the same name)
    static func createFile(named name: String, contents: String) -> ShellOutCommand {
        var command = "echo"
        command.append(argument: contents)
        command.append(" > ")
        command.append(argument: name)

        return ShellOutCommand(string: command)
    }

    /// Move a file from one path to another
    static func moveFile(from originPath: String, to targetPath: String) -> ShellOutCommand {
        let command = "mv".appending(argument: originPath)
                          .appending(argument: targetPath)

        return ShellOutCommand(string: command)
    }
    
    /// Copy a file from one path to another
    static func copyFile(from originPath: String, to targetPath: String) -> ShellOutCommand {
        let command = "cp".appending(argument: originPath)
                          .appending(argument: targetPath)
        
        return ShellOutCommand(string: command)
    }
    
    /// Remove a file
    static func removeFile(from path: String, arguments: [String] = ["-f"]) -> ShellOutCommand {
        let command = "rm".appending(arguments: arguments)
                          .appending(argument: path)
        
        return ShellOutCommand(string: command)
    }

    /// Open a file using its designated application
    static func openFile(at path: String) -> ShellOutCommand {
        let command = "open".appending(argument: path)
        return ShellOutCommand(string: command)
    }

    /// Read a file as a string
    static func readFile(at path: String) -> ShellOutCommand {
        let command = "cat".appending(argument: path)
        return ShellOutCommand(string: command)
    }

    /// Create a symlink at a given path, to a given target
    static func createSymlink(to targetPath: String, at linkPath: String) -> ShellOutCommand {
        let command = "ln -s".appending(argument: targetPath)
                             .appending(argument: linkPath)

        return ShellOutCommand(string: command)
    }

    /// Expand a symlink at a given path, returning its target path
    static func expandSymlink(at path: String) -> ShellOutCommand {
        let command = "readlink".appending(argument: path)
        return ShellOutCommand(string: command)
    }
}

/// Marathon commands
public extension ShellOutCommand {
    /// Run a Marathon Swift script
    static func runMarathonScript(at path: String, arguments: [String] = []) -> ShellOutCommand {
        let command = "marathon run".appending(argument: path)
                                    .appending(arguments: arguments)

        return ShellOutCommand(string: command)
    }

    /// Update all Swift packages managed by Marathon
    static func updateMarathonPackages() -> ShellOutCommand {
        return ShellOutCommand(string: "marathon update")
    }
}

/// Swift Package Manager commands
public extension ShellOutCommand {
    /// Enum defining available package types when using the Swift Package Manager
    enum SwiftPackageType: String {
        case library
        case executable
    }

    /// Enum defining available build configurations when using the Swift Package Manager
    enum SwiftBuildConfiguration: String {
        case debug
        case release
    }

    /// Create a Swift package with a given type (see SwiftPackageType for options)
    static func createSwiftPackage(withType type: SwiftPackageType = .library) -> ShellOutCommand {
        let command = "swift package init --type \(type.rawValue)"
        return ShellOutCommand(string: command)
    }

    /// Update all Swift package dependencies
    static func updateSwiftPackages() -> ShellOutCommand {
        return ShellOutCommand(string: "swift package update")
    }

    /// Generate an Xcode project for a Swift package
    static func generateSwiftPackageXcodeProject() -> ShellOutCommand {
        return ShellOutCommand(string: "swift package generate-xcodeproj")
    }

    /// Build a Swift package using a given configuration (see SwiftBuildConfiguration for options)
    static func buildSwiftPackage(withConfiguration configuration: SwiftBuildConfiguration = .debug) -> ShellOutCommand {
        return ShellOutCommand(string: "swift build -c \(configuration.rawValue)")
    }

    /// Test a Swift package using a given configuration (see SwiftBuildConfiguration for options)
    static func testSwiftPackage(withConfiguration configuration: SwiftBuildConfiguration = .debug) -> ShellOutCommand {
        return ShellOutCommand(string: "swift test -c \(configuration.rawValue)")
    }
}

/// Fastlane commands
public extension ShellOutCommand {
    /// Run Fastlane using a given lane
    static func runFastlane(usingLane lane: String) -> ShellOutCommand {
        let command = "fastlane".appending(argument: lane)
        return ShellOutCommand(string: command)
    }
}

/// CocoaPods commands
public extension ShellOutCommand {
    /// Update all CocoaPods dependencies
    static func updateCocoaPods() -> ShellOutCommand {
        return ShellOutCommand(string: "pod update")
    }

    /// Install all CocoaPods dependencies
    static func installCocoaPods() -> ShellOutCommand {
        return ShellOutCommand(string: "pod install")
    }
}

/// Error type thrown by the `shellOut()` function, in case the given command failed
public struct ShellOutError: Swift.Error {
    /// The termination status of the command that was run
    public let terminationStatus: Int32
    /// The error message as a UTF8 string, as returned through `STDERR`
    public var message: String { return errorData.shellOutput() }
    /// The raw error buffer data, as returned through `STDERR`
    public let errorData: Data
    /// The raw output buffer data, as retuned through `STDOUT`
    public let outputData: Data
    /// The output of the command as a UTF8 string, as returned through `STDOUT`
    public var output: String { return outputData.shellOutput() }
}

extension ShellOutError: CustomStringConvertible {
    public var description: String {
        return """
               ShellOut encountered an error
               Status code: \(terminationStatus)
               Message: "\(message)"
               Output: "\(output)"
               """
    }
}

extension ShellOutError: LocalizedError {
    public var errorDescription: String? {
        return description
    }
}

// MARK: - Private

private extension Process {
    @discardableResult func launchBash(with command: String, outputHandle: FileHandle? = nil, errorHandle: FileHandle? = nil) throws -> String {
        launchPath = "/bin/bash"
        arguments = ["-c",command]
        var home:String
        if #available(OSX 10.12, *) {
            home = FileManager.default.homeDirectoryForCurrentUser.path
        } else {
            // Fallback on earlier versions
            home = URL(fileURLWithPath: NSHomeDirectory()).path

        }
        environment = ["LANG": "en_US.UTF-8",
                        "PATH": "$PATH:$HOME/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/sbin:/usr/local/bin",
                        "LC_ALL": "en_US.UTF-8",
                        "HOME": home]
        

        // Because FileHandle's readabilityHandler might be called from a
        // different queue from the calling queue, avoid a data race by
        // protecting reads and writes to outputData and errorData on
        // a single dispatch queue.
        let outputQueue = DispatchQueue(label: "bash-output-queue")

        var outputData = Data()
        var errorData = Data()

        let outputPipe = Pipe()
        
        standardOutput = outputPipe

        let errorPipe = Pipe()
        standardError = errorPipe

        #if !os(Linux)
        outputPipe.fileHandleForReading.readabilityHandler = { handler in
            outputQueue.async {
                let data = handler.availableData
                print(String(data: data, encoding: String.Encoding.utf8) ?? "")
                outputData.append(data)
                outputHandle?.write(data)
            }
        }

        errorPipe.fileHandleForReading.readabilityHandler = { handler in
            outputQueue.async {
                let data = handler.availableData
                errorData.append(data)
                errorHandle?.write(data)
            }
        }
        #endif

        launch()

        #if os(Linux)
        outputQueue.sync {
            outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        }
        #endif

        waitUntilExit()

        outputHandle?.closeFile()
        errorHandle?.closeFile()

        #if !os(Linux)
        outputPipe.fileHandleForReading.readabilityHandler = nil
        errorPipe.fileHandleForReading.readabilityHandler = nil
        #endif

        // Block until all writes have occurred to outputData and errorData,
        // and then read the data back out.
        return try outputQueue.sync {
            if terminationStatus != 0 {
                throw ShellOutError(
                    terminationStatus: terminationStatus,
                    errorData: errorData,
                    outputData: outputData
                )
            }

            return outputData.shellOutput()
        }
    }
}

private extension Data {
    func shellOutput() -> String {
        guard let output = String(data: self, encoding: .utf8) else {
            return ""
        }

        guard !output.hasSuffix("\n") else {
            let endIndex = output.index(before: output.endIndex)
            return String(output[..<endIndex])
        }

        return output

    }
}

private extension String {
    var escapingSpaces: String {
        return replacingOccurrences(of: " ", with: "\\ ")
    }

    func appending(argument: String) -> String {
        return "\(self) \"\(argument)\""
    }

    func appending(arguments: [String]) -> String {
        return appending(argument: arguments.joined(separator: "\" \""))
    }

    mutating func append(argument: String) {
        self = appending(argument: argument)
    }

    mutating func append(arguments: [String]) {
        self = appending(arguments: arguments)
    }
}
