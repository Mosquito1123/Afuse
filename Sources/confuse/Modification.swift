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
    
        //字符串硬编码混淆不需要替换objc文件的头部；
        //方法混淆需要；
       
    }
    public class func replaceMFile(_ mFilePath:String?){
        
        print(mFilePath ?? "")
        guard let path = mFilePath else {
            return
        }
        let headerString = (path as NSString).lastPathComponent.replacingOccurrences(of: ".m", with: ".h").replacingOccurrences(of: "+", with: "\\+")
        let importHeaderString = "#import \"\(headerString)\""
        let url = URL(fileURLWithPath: path)
        do{
            let content = try String(contentsOf: url, encoding: String.Encoding.utf8)
            if content.contains(Template.des_confuse_define) == false{
                let replacedContent = content.replacingOccurrences(of: importHeaderString, with: "$0\n\(Template.des_confuse_define)", options: String.CompareOptions.regularExpression, range: nil)
                try replacedContent.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            }
        }catch let error{
            print(error)
        }
    }
    public class func matchStrings(_ mFilePath:String?,_ classConfig:ClassConfig){
        guard let path = mFilePath else {
            return
        }
        
        let url = URL(fileURLWithPath: path)
        do{
            let content = try String(contentsOf: url, encoding: String.Encoding.utf8)
            var replacedContent = content
            if let confuseStrings = classConfig.confuseStrings{
                for confuseString in confuseStrings {
                    
                    let objcOldString = "@\"\(confuseString)\""
                    if let encryptedString = DES3EncryptUtil.encrypt(confuseString){
                        let objcNewString = "des_decrypt(@\"\(encryptedString)\")"
                        replacedContent = replacedContent.replacingOccurrences(of: objcOldString, with: objcNewString, options: String.CompareOptions.regularExpression, range: nil)
                    }
                }
                
                
            }
            if let _ = classConfig.confuseRegexs{
                
                var results = Modification.matches(for: "(https?|ftp|file|wss?)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]", in: replacedContent)
                results.removeAll { (result) -> Bool in
                    return classConfig.ignoreStrings?.contains(result) == true
                }
                for result in results{
                    let objcOldString = "@\"\(result)\""
                    if let encryptedString = DES3EncryptUtil.encrypt(result){
                        let objcNewString = "des_decrypt(@\"\(encryptedString)\")"
                        replacedContent = replacedContent.replacingOccurrences(of: objcOldString, with: objcNewString, options: String.CompareOptions.regularExpression, range: nil)
                    }
                }
                
            }
            try replacedContent.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            
            
        }catch let error{
            print(error)
        }
    }
   
    class func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
            
            
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
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
