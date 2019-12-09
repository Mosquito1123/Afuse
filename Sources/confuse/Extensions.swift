//
//  File.swift
//  
//
//  Created by Mosquito1123 on 03/12/2019.
//

import Foundation


//添加路径扩展
extension String {
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
}
//拷贝整个文件夹内容
public extension FileManager{
    func copyFile(fpath:String,tpath:String) throws {
        //如果已存在，先删除，否则拷贝不了
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: tpath){
            try fileManager.removeItem(atPath: tpath)
        }
        
        try fileManager.copyItem(atPath: fpath, toPath: tpath)
    }
}
