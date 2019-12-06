//
//  File.swift
//  
//
//  Created by Mosquito1123 on 30/11/2019.
//

import Foundation
public class AutoConfuse{
    
    //自动混淆
    
    /// 自动混淆函数
    /// - Parameter input: 工程根目录（必须）
    /// - Parameter mainGroupName: 要混淆的子目录名称（必须）
    /// - Parameter handleAssets: 是否混图片（可选）
    /// - Parameter needDeleteComments: 是否删除修改注释（可选）
    /// - Parameter modifyProjectNameParams: 修改工程名（可选）
    /// - Parameter modifyClassNamePrefixParams: 修改工程前缀（可选）
    /// - Parameter dirNamesString: 忽略文件夹目录（可选）
    public class func auto_confuse(inputDir input:String?,mainGroup mainGroupName:String?="Tortoise",needHandlerAssets handleAssets:Bool=true,needDeleteComments:Bool=true,modifyProjectName modifyProjectNameParams:String? = nil,modifyClassNamePrefix modifyClassNamePrefixParams:String? = nil,ignoreDirNames dirNamesString:String? = nil){
        
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
    public class func buildFramework(inputDir input:String?,mainGroup name:String?){
        AutoConfuse.auto_confuse(inputDir: input,mainGroup: name)
        do {
            let projectPath = input ?? ""
            let target = name ?? "Tortoise"
            let result = try shellOut(to: .installCocoaPods(),at: projectPath)
            print(result)
            try shellOut(to: "/bin/rm -rf build",at: projectPath)
            try shellOut(to: "/bin/mkdir build",at: projectPath)
            let iphoneos = try shellOut(to: "/usr/bin/xcodebuild", arguments: ["-target","\(target)","ONLY_ACTIVE_ARCH=NO","-configuration","'Release'","-sdk","iphoneos","clean","build"], at: projectPath)
            print(iphoneos)
            let iphonesimulator = try shellOut(to: "/usr/bin/xcodebuild", arguments: ["-target","\(target)","ONLY_ACTIVE_ARCH=NO","-configuration","'Release'","-sdk","iphonesimulator","clean","build"], at: projectPath)
            
            print(iphonesimulator)
            try shellOut(to: "/usr/bin/lipo", arguments:["-create",""])
        } catch let error {
            print(error)
        }
        /*
        if let result = shell("/usr/local/bin/pod", ["install", "--project-directory=\(input ?? "")"]).0{
            print(result)

            
            let frameworkName = (name ?? "Tortoise").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let workDir = "build"
            let deviceDir = "\(workDir)/Release-iphoneos/\(frameworkName).framework"
            let simulatorDir = "\(workDir)/Release-iphonesimulator/\(frameworkName).framework"
            if let outputDir = input?.stringByAppendingPathComponent(path: "Products").stringByAppendingPathComponent(path: "\(frameworkName).framework"){
                shell("/usr/bin/cd",["\(input ?? "")"])
                shell("/usr/bin/xcodebuild", ["-target","\(frameworkName)","ONLY_ACTIVE_ARCH=NO","-configuration","'Release'","-sdk","iphoneos","clean","build"])
                shell("/usr/bin/xcodebuild", ["-target","\(frameworkName)","ONLY_ACTIVE_ARCH=NO","-configuration","'Release'","-sdk","iphonesimulator","clean","build"])

                if FileManager.default.fileExists(atPath: outputDir){
                    do {
                        try  FileManager.default.removeItem(atPath: outputDir)
                    } catch let error {
                        print(error)
                    }
                }
                
                
                do {
                    try FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: nil)
//                    try FileManager.default.copyFile(fpath: deviceDir, tpath: outputDir)
                } catch let error {
                    print(error)
                }
                shell("/usr/bin/lipo",["-create","\(deviceDir)/\(frameworkName)","\(simulatorDir)/\(frameworkName)","-output","\(outputDir)/\(frameworkName)"])
//                shell("/bin/rm",["-rf","\(workDir)"])
                
               
            }

        }
 */
    }
}
//cd input && pod install
