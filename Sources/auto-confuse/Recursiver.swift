//
//  File.swift
//  
//
//  Created by Mosquito1123 on 27/11/2019.
//

import Foundation
import objc
public class Recursiver{
    public func swift_recursiveDirectory(directory path:String,ignoreDirNames names:[String],handleMFile handler:@escaping ((_ mFilePath:String?)->Void),handleSwiftFile swiftHandler:@escaping ((_ swiftFilePath:String?)->Void))  {
        recursiveDirectory(path, names, handler, swiftHandler)
       
    }

}
