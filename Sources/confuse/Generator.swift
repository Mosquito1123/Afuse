//
//  File.swift
//  
//
//  Created by Mosquito1123 on 27/11/2019.
//

import Foundation
import objc_confuse
public class Generator{
    //生成垃圾代码
    public func swift_generateSpamCodeFile(outDirectory out:String,mFilePath mfile:String,sourceType type:GSCSourceType,categoryCallImportString categoryCallImport:NSMutableString,categoryCallFuncString categoryCallFunc:NSMutableString,newClassCallImportString newClassCallImport:NSMutableString,newClassCallFuncString newClassCallFunc:NSMutableString){
    
       generateSpamCodeFile(out, mfile, type, categoryCallImport, categoryCallFunc, newClassCallImport, newClassCallFunc)
    }
    //生成Swift版本的垃圾代码
    public func swift_generateSwiftSpamCodeFile(outDirectory out:String,swiftFilePath swiftFile:String){
        generateSwiftSpamCodeFile(out, swiftFile)
    }
   
 
}
