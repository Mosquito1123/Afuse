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
}
