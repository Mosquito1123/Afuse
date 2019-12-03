//
//  File.swift
//  
//
//  Created by Mosquito1123 on 27/11/2019.
//

import Foundation

import objc_confuse




public class Modification{
   
    
    public class func replaceHeader(_ mFilePath:String?){
    
        print(mFilePath ?? "")
        guard let path = mFilePath?.replacingOccurrences(of: ".m", with: ".h") else {
            return
        }
        let url = URL(fileURLWithPath: path)
        do{
            let content = try String(contentsOf: url, encoding: String.Encoding.utf8)
            if content.contains("#import \"DES3EncryptUtil.h\"") == false{
                let replacedContent = content.replacingOccurrences(of: Template.des_origin_import, with: Template.des_encrypt_define)
                try replacedContent.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            }
            
        }catch let error{
            print(error)
        }
    }
    public class func replaceMFile(){
        
    }
    public class func matchStrings(){
        
    }
   
    
    //修改工程名
    public class func executeModifyProjectName(_ directory:String?,_ paramsString:String?){
        let old = paramsString?.components(separatedBy: ">").first
        let new = paramsString?.components(separatedBy: ">").last
        swift_modifyProjectName(projectDir: directory, name: old, name: new)
        /*
        guard let projectPath = directory else {return}
        let path = projectPath.stringByAppendingPathComponent(path: "Podfile")
        if FileManager.default.fileExists(atPath: path) {
            print(path)
            do {
                try shellOut(to: .installCocoaPods(),at: projectPath)
            } catch let error {
                print(error)
            }
        }
 */
        
        
    }
    //修改类名前缀
    public class func executeModifyClassNamePrefix(_ directory:String?,_ ignoreDirNames:[String]!,_ paramsString:String?){
        guard let sourcePath = paramsString?.components(separatedBy: " ").first?.stringByAppendingPathComponent(path: "project.pbxproj") else {
            print("文件不存在")
            return  }
        let old = paramsString?.components(separatedBy: " ").last?.components(separatedBy: ">").first
        let new = paramsString?.components(separatedBy: " ").last?.components(separatedBy: ">").last
        do {
            let content = try NSMutableString(contentsOfFile: sourcePath, encoding: String.Encoding.utf8.rawValue)
            swift_modifyClassNamePrefix(project: content, sourceCodeDir: directory, ignoreDirNames: ignoreDirNames, name: old, name: new)
        } catch let error {
            print(error)
        }
        
    }
    public class func swift_modifyProjectName(projectDir path:String!,name old:String!,name new:String!){
        modifyProjectName(path, old, new)
    }
    public class func swift_modifyClassNamePrefix(project content:NSMutableString?,sourceCodeDir dirPath:String!,ignoreDirNames names:[String]!,name old:String!,name new:String!){
        modifyClassNamePrefix(content, dirPath, names, old, new)
    }
}
