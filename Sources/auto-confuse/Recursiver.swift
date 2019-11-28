//
//  File.swift
//  
//
//  Created by Mosquito1123 on 27/11/2019.
//

import Foundation
import objc
public class Recursiver{
    public func recursive(directory input:String?,ignoreDirNames names:[String]?,handleMFile handler:@escaping ((_ mFilePath:String?)->Void),handleSwiftFile swiftHandler:@escaping ((_ swiftFilePath:String?)->Void)){
        guard let validInput = self.validInput(input) else{
            return
        }
        guard let dirNames = names else{
            return
        }
        self.swift_recursiveDirectory(directory: validInput, ignoreDirNames: dirNames, handleMFile: handler, handleSwiftFile: swiftHandler)
    }
    
    public func validInput(_ input:String?)->String?{
    
        guard let xInput = input else {
            print("Missing required options: [\"-i, --input\"]")
            return nil
        }
        let fm = FileManager.default
        var isDirectory:ObjCBool = false
        
        if fm.fileExists(atPath: xInput, isDirectory: &isDirectory) == true {
            if isDirectory.boolValue == true {
                return xInput
            }else{
                print("\(xInput)不是目录\n")
                return nil
            }
        }else{
            print("\(xInput)目录不存在\n")
            return nil
        }
    }
    public func swift_recursiveDirectory(directory path:String,ignoreDirNames names:[String],handleMFile handler:@escaping ((_ mFilePath:String?)->Void),handleSwiftFile swiftHandler:@escaping ((_ swiftFilePath:String?)->Void))  {
        
        recursiveDirectory(path, names, handler, swiftHandler)
       
    }

}
