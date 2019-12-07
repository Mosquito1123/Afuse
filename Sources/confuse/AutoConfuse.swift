//
//  File.swift
//  
//
//  Created by Mosquito1123 on 30/11/2019.
//

import Foundation

public class AutoConfuse{
    public class func fetchProjectFromGit(_ gitRepositoryPath:String,_ localPath:String?,successBlock success:(Int,String,String?)->Void,failureBlock failure:(Int,String,String?)->Void) throws {

        var path:String
        if let localPath = localPath {
            path = localPath
            let uuid = UUID().uuidString
            path = localPath.stringByAppendingPathComponent(path: uuid)

            let lastComponent = gitRepositoryPath.components(separatedBy: "/").last
            if let directoryname = lastComponent?.components(separatedBy: ".").first {
                path =  path.stringByAppendingPathComponent(path: directoryname)
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }
           
            
        }else{
            var home:String
            if #available(OSX 10.12, *) {
                home = FileManager.default.homeDirectoryForCurrentUser.path
            } else {
                // Fallback on earlier versions
                home = URL(fileURLWithPath: NSHomeDirectory()).path

            }
            
            let uuid = UUID().uuidString
            path = home.stringByAppendingPathComponent(path: "Desktop").stringByAppendingPathComponent(path: uuid)

            let lastComponent = gitRepositoryPath.components(separatedBy: "/").last
            if let directoryname = lastComponent?.components(separatedBy: ".").first {
                path =  path.stringByAppendingPathComponent(path: directoryname)
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }
           
        }
      

        let result = CommandRunner.sync(shellPath: "/usr/bin/git", arguments: ["clone",gitRepositoryPath,path])
        
    
        if result.0 == 0 {
            

            success(result.0,result.1,path)
            
        }else{

            failure(result.0,result.1,nil)
        }

    }
    
    //自动混淆
    
    /// 自动混淆函数
    /// - Parameter input: 工程根目录（必须）
    /// - Parameter mainGroupName: 要混淆的子目录名称（必须）
    /// - Parameter handleAssets: 是否混图片（可选）
    /// - Parameter needDeleteComments: 是否删除修改注释（可选）
    /// - Parameter modifyProjectNameParams: 修改工程名（可选）
    /// - Parameter modifyClassNamePrefixParams: 修改工程前缀（可选）
    /// - Parameter dirNamesString: 忽略文件夹目录（可选）
    public class func autoConfuse(inputDir input:String?,mainGroup mainGroupName:String?="Tortoise",needHandlerAssets handleAssets:Bool=true,needDeleteComments:Bool=true,modifyProjectName modifyProjectNameParams:String? = nil,modifyClassNamePrefix modifyClassNamePrefixParams:String? = nil,ignoreDirNames dirNamesString:String? = nil){
        
        let ignoreDirNames = dirNamesString?.components(separatedBy: ",") ?? []
        print("IgnoreDir names are \(ignoreDirNames)")



        Preparation.shared.prepare_shell_script(input)
        Preparation.shared.prepare_to_confuse(input)
        Preparation.shared.prepare_to_decode_confuse(input)
            
        Preparation.shared.prepare_des_confuse_and_decode_confuse(input)
        Confusion.confuse()
        var config:Config?
        do {
            if let data = Template.tortoiseStructure.data(using: String.Encoding.utf8){
                let result = try JSONDecoder().decode(Config.self, from: data)
                print(result)
                config = result
            }
        
            
        } catch let error {
            print(error)
        }
        let input = Recursiver.validInput(input)
        
        Recursiver.swift_recursiveDirectory(directory: input ?? "", ignoreDirNames: ignoreDirNames, handleMFile: { (mFilePath) in

            if mFilePath?.contains(mainGroupName ?? "Tortoise") == true{
                config?.array?.forEach({ (conf) in
                    if let className = conf.className{
                        if mFilePath?.contains(className) == true{
                            Modification.replaceMFile(mFilePath)
                            Modification.matchStrings(mFilePath,conf)
                        }
                    }else{
                        return
                        
                    }
                })
                
                
            }
        }) { (swiftFilePath) in
            print(swiftFilePath ?? "")
        }
        if handleAssets == true{
            Handler.executeConfuseAssetsFiles(assetsDirectory: input)

        }
        if needDeleteComments == true{
            Deletion.executeDeleteComment(directoryPath: input, ignoreDirNames: ignoreDirNames)

        }
        Modification.executeModifyProjectName(input,modifyProjectNameParams)
        Modification.executeModifyClassNamePrefix(input,ignoreDirNames,modifyClassNamePrefixParams)

        
     
    }
    public class func buildFramework(inputDir input:String?,mainGroup name:String?,output success:(_ frameworkpath:String)->Void,error failure:(_ error:Error)->Void){
        AutoConfuse.autoConfuse(inputDir: input,mainGroup: name)
        do {
            let projectPath = input ?? ""
            let projectName = (projectPath as NSString).lastPathComponent
            let workSpaceName = "\(projectName).xcworkspace"
            let target = name ?? "Tortoise"
            let result = try shellOut(to: .installCocoaPods(),at: projectPath)
            print(result)
            try shellOut(to: "/bin/rm -rf build",at: projectPath)
            try shellOut(to: "/bin/mkdir build",at: projectPath)

            try shellOut(to: "/bin/chmod 777 build",at: projectPath)
            try shellOut(to: "/bin/rm -rf build/Build",at:projectPath)

            try shellOut(to: "cd \(projectPath)")
            let tuple = CommandRunner.sync(shellPath: "/usr/bin/xcodebuild", arguments: ["-scheme","\(target)","-workspace","\(projectPath)/\(workSpaceName)","ONLY_ACTIVE_ARCH=NO","-configuration","'Release'","-sdk","iphoneos","clean","build","-derivedDataPath","\(projectPath)/build"])
            let status = tuple.0
            print(tuple.1)
            if status == 0 {
                do{
                    let rename = try shellOut(to: "/bin/mv \(projectPath)/build/Build/Products/Release-iphoneos/\(target).framework \(projectPath)/build/\(UUID().uuidString).framework",at: projectPath)
                               print(rename)
                    print(status)
                    success("\(projectPath)/build/\(UUID().uuidString).framework")

                }catch let error{
                    print(error)
                    failure(error)
                    
                }
            }else{
                print(tuple.1)
            }
            
            

        } catch let error {
            print(error)
            failure(error)

        }

    }
}
//cd input && pod install
