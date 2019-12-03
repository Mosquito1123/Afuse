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
    public var confuseStrings:[String]?
    public var confuseRegexs:[String]?
}