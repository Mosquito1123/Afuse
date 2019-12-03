//
//  File.swift
//  
//
//  Created by Mosquito1123 on 03/12/2019.
//

import Foundation
import XcodeProj
import PathKit

public class Preparation{
    public static let shared = Preparation()
    public var confusionPath:String?
    public var decodeConfusionPath:String?
    
    /// git clone 方法
    /// - Parameter path: git 地址
    public func checkout(_ path:String = Const.git_ssh_path){
        do {
        
            
            if let url = URL(string: path){
                try shellOut(to: .gitClone(url: url))

            }
        } catch let error {
            print(error)
        }
    }
    //confuse
    public func prepare_to_confuse(_ dirPath:String?,_ mainGroup:String? = nil){
        guard let confusionPath = dirPath?.stringByAppendingPathComponent(path: "confusion.py") else {return}
        self.confusionPath = confusionPath
        
        let confusionURL = URL(fileURLWithPath: confusionPath)

        do {
            try Template.confusion().data(using: String.Encoding.utf8)?.write(to: confusionURL)
        } catch let error {
            print(error)
        }
        
    }
    //decodeConfusion
    public func prepare_to_decode_confuse(_ dirPath:String?,_ mainGroup:String? = nil){
        guard let decodeConfusionPath = dirPath?.stringByAppendingPathComponent(path: "decodeConfusion.py") else {return}
        self.decodeConfusionPath = decodeConfusionPath

        let decodeConfusionURL = URL(fileURLWithPath: decodeConfusionPath)
        do {
            try Template.decodeConfusion().data(using: String.Encoding.utf8)?.write(to: decodeConfusionURL)
        } catch let error {
            print(error)
        }

    }
    
    public func prepare_des_confuse_and_decode_confuse(_ dirPath:String?,_ mainGroup:String? = "Tortoise"){
        guard let input = dirPath else {return}
        let xcodeprojName = (input as NSString).lastPathComponent

        guard let main_group_path = dirPath?.stringByAppendingPathComponent(path: mainGroup ?? "") else {
            return
        }
        if FileManager.default.fileExists(atPath: main_group_path) == false{
            do {
                try FileManager.default.createDirectory(atPath: main_group_path, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print(error)
            }
            
        }
        let base64_h = main_group_path.stringByAppendingPathComponent(path: "MyBase64.h")
        let base64_m = main_group_path.stringByAppendingPathComponent(path: "MyBase64.m")
        let des_h = main_group_path.stringByAppendingPathComponent(path: "DES3EncryptUtil.h")
        let des_m = main_group_path.stringByAppendingPathComponent(path: "DES3EncryptUtil.m")
        let base64_h_url = URL(fileURLWithPath: base64_h)
        let base64_m_url = URL(fileURLWithPath: base64_m)
        let des_h_url = URL(fileURLWithPath: des_h)
        let des_m_url = URL(fileURLWithPath: des_m)
        do {
            try Template.base64_h.data(using: String.Encoding.utf8)?.write(to: base64_h_url)
            try Template.base64_m.data(using: String.Encoding.utf8)?.write(to: base64_m_url)
            try Template.des_h().data(using: String.Encoding.utf8)?.write(to: des_h_url)
            try Template.des_m().data(using: String.Encoding.utf8)?.write(to: des_m_url)

            let path =  Path(components: [input,"\(xcodeprojName).xcodeproj"])
            
            let xcodeproj = try XcodeProj(path: path)
            if let project = xcodeproj.pbxproj.projects.first,let main_group = project.mainGroup{
            
                let refer_base64_h = try main_group.addFile(at: Path(base64_h), sourceRoot: Path(input))
                let refer_base64_m = try main_group.addFile(at: Path(base64_m), sourceRoot: Path(input))
                let refer_des_h = try main_group.addFile(at: Path(des_h), sourceRoot: Path(input))
               let refer_des_m =  try main_group.addFile(at: Path(des_m), sourceRoot: Path(input))


//                xcodeproj.pbxproj.add(object: refer_base64_h)
//                xcodeproj.pbxproj.add(object: refer_base64_m)
//
//                xcodeproj.pbxproj.add(object: refer_des_h)
//
//                xcodeproj.pbxproj.add(object: refer_des_m)

                let groupx = try xcodeproj.pbxproj.rootGroup()
                
                print(groupx?.group(named: "Tortoise"))
                try project.targets.forEach { (target) in
                    print(target.name)
                    if target.name == mainGroup{
                        print(target.buildPhases)
                    
                        let _ = try target.sourcesBuildPhase()?.add(file: refer_base64_h)
                        let _ = try target.sourcesBuildPhase()?.add(file: refer_base64_m)
                        let _ = try target.sourcesBuildPhase()?.add(file: refer_des_h)
                        let _ = try target.sourcesBuildPhase()?.add(file: refer_des_m)

                    }
                    
                }
                
                print(project.targets)
            }
            try xcodeproj.write(path: path)

            // 3. add file to the project, if needed
            

            // 5. add file to the target, if needed

        } catch let error {
            print(error)
        }

        
        
    }
}