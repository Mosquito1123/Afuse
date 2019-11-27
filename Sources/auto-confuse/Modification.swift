//
//  File.swift
//  
//
//  Created by Mosquito1123 on 27/11/2019.
//

import Foundation
import objc
public class Modification{
      public func swift_modifyProjectName(projectDir path:String,name old:String,name new:String){
        modifyProjectName(path, old, new)
      }
      public func swift_modifyClassNamePrefix(project content:NSMutableString,sourceCodeDir dirPath:String,ignoreDirNames names:[String],name old:String,name new:String){
        modifyClassNamePrefix(content, dirPath, names, old, new)
      }
}
