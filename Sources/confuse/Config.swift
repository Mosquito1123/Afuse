//
//  File.swift
//  
//
//  Created by Mosquito1123 on 03/12/2019.
//

import Foundation

public struct Config:Codable{
    public var array:[ClassConfig]?
}
public struct ClassConfig:Codable{
    public var className:String?
    public var type:ClassType?
    public var confuseStrings:[String]?
    public var confuseRegexs:[String]?
    public var ignoreStrings:[String]?
}
public enum ClassType:Int,Codable{
    case objc
    case swift
}
