//
//  File.swift
//  
//
//  Created by Mosquito1123 on 03/12/2019.
//

import Foundation

public class Preparation{
    public static let shared = Preparation()
    public var confusionPath:String?
    public var decodeConfusionPath:String?
    //confuse
    public func prepare_to_confuse(_ dirPath:String?){
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
    public func prepare_to_decode_confuse(_ dirPath:String?){
        guard let decodeConfusionPath = dirPath?.stringByAppendingPathComponent(path: "decodeConfusion.py") else {return}
        self.decodeConfusionPath = decodeConfusionPath

        let decodeConfusionURL = URL(fileURLWithPath: decodeConfusionPath)
        do {
            try Template.decodeConfusion().data(using: String.Encoding.utf8)?.write(to: decodeConfusionURL)
        } catch let error {
            print(error)
        }

    }
    
    public func prepare_des_confuse_and_decode_confuse(_ dirPath:String?){
        
        guard let base64_h = dirPath?.stringByAppendingPathComponent(path: "MyBase64.h") else {return}
        guard let base64_m = dirPath?.stringByAppendingPathComponent(path: "MyBase64.m") else {return}
        guard let des_h = dirPath?.stringByAppendingPathComponent(path: "DES3EncryptUtil.h") else {return}
        guard let des_m = dirPath?.stringByAppendingPathComponent(path: "DES3EncryptUtil.m") else {return}
        let base64_h_url = URL(fileURLWithPath: base64_h)
        let base64_m_url = URL(fileURLWithPath: base64_m)
        let des_h_url = URL(fileURLWithPath: des_h)
        let des_m_url = URL(fileURLWithPath: des_m)
        do {
            try Template.base64_h.data(using: String.Encoding.utf8)?.write(to: base64_h_url)
            try Template.base64_m.data(using: String.Encoding.utf8)?.write(to: base64_m_url)
            try Template.des_h().data(using: String.Encoding.utf8)?.write(to: des_h_url)
            try Template.des_m().data(using: String.Encoding.utf8)?.write(to: des_m_url)

        } catch let error {
            print(error)
        }

        
    }
}
