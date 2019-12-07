import Foundation
import CommandLineKit
import SwiftShell
import confuse
import XcodeProj
import PathKit

extension String {
    var boolValue: Bool? {
        switch self.lowercased() {
        case "true", "t", "yes", "y", "1":
            return true
        case "false", "f", "no", "n", "0":
            return false
        default:
            return nil
        }
    }
}
//命令行
let cli = CommandLineKit.CommandLine()

let help = BoolOption(shortFlag: "h", longFlag: "help",
  helpMessage: "Prints a help message.")
let verbosity = CounterOption(shortFlag: "v", longFlag: "verbose",
  helpMessage: "Print verbose messages. Specify multiple times to increase verbosity.")





let filePathx = StringOption(shortFlag: "i", longFlag: "input", required: true,
  helpMessage: "Path to the input file.")
let mainGroupx = StringOption(shortFlag: "M", longFlag: "mainGroup", required: true,
helpMessage: "MainGroup To Confuse.")
let spamCodeOutPathx = StringOption(shortFlag: "s", longFlag: "spamCodeOut",
  helpMessage: "Generate spam code output path.For example:path,paramName,oldFunc,newClass")
let handleXcassetsx = StringOption(shortFlag: "x", longFlag: "handleXcassets",
helpMessage: "Handle xcassets confuse.")
let deleteCommentsx = StringOption(shortFlag: "d", longFlag: "deleteComments",
helpMessage: "Delete comments.")
let modifyProjectNamex = StringOption(shortFlag: "m", longFlag: "modifyProjectName",
helpMessage: "Modify ProjectName.Format:OldName>NewName.For example:DDApp>CCApp.")
let modifyClassNamePrefixx = StringOption(shortFlag: "p", longFlag: "modifyClassNamePrefix",
helpMessage: "Modify Project ClassNamePrefix.Format:Project OldClassNamePrefix>NewClassNamePrefix.For example:DDAppPath DDApp>CCApp.")
let ignoreDirNamesx = StringOption(shortFlag: "g", longFlag: "ignoreDirNames",
helpMessage: "Ignore dirNames.Format:A,B,C....For example:DDApp,CCApp,BBApp....")


cli.addOptions(filePathx,mainGroupx,spamCodeOutPathx,handleXcassetsx,deleteCommentsx,modifyProjectNamex,modifyClassNamePrefixx,ignoreDirNamesx)
do {
  try cli.parse()
} catch let error{
  cli.printUsage(error)
}
let handleAssets = handleXcassetsx.value?.boolValue ?? false
let deleteComments = deleteCommentsx.value?.boolValue ?? false
do {
    try AutoConfuse.fetchProjectFromGit("git@gitlab.baifu-tech.net:engineering-lion/chess/chess-shell-ios.git", nil, successBlock: { (status, output, path) in
        AutoConfuse.autoConfuse(inputDir: path,mainGroup:mainGroupx.value, needHandlerAssets: handleAssets, needDeleteComments: deleteComments, modifyProjectName: modifyProjectNamex.value, modifyClassNamePrefix: modifyClassNamePrefixx.value, ignoreDirNames: ignoreDirNamesx.value)

        AutoConfuse.buildFramework(inputDir: path, mainGroup: mainGroupx.value, output: { (path) in
            print(path)
        }) { (error) in
            print(error)
        }
    }, failureBlock: { (status, output, error) in
        print(status,output)

    })

    

} catch let error {
    print(error)
}
AutoConfuse.autoConfuse(inputDir: filePathx.value,mainGroup:mainGroupx.value, needHandlerAssets: handleAssets, needDeleteComments: deleteComments, modifyProjectName: modifyProjectNamex.value, modifyClassNamePrefix: modifyClassNamePrefixx.value, ignoreDirNames: ignoreDirNamesx.value)

AutoConfuse.buildFramework(inputDir: filePathx.value, mainGroup: mainGroupx.value, output: { (path) in
    print(path)
}) { (error) in
    print(error)
}



