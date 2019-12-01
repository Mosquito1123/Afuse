//
//  File.swift
//  
//
//  Created by Mosquito1123 on 27/11/2019.
//

import Foundation
import objc_confuse



//添加路径扩展
extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}
public class Modification{
    //修改工程名
    public class func executeModifyProjectName(_ directory:String?,_ paramsString:String?){
        let old = paramsString?.components(separatedBy: ">").first
        let new = paramsString?.components(separatedBy: ">").last
        swift_modifyProjectName(projectDir: directory, name: old, name: new)
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
