//
//  File.swift
//  
//
//  Created by Mosquito1123 on 27/11/2019.
//

import Foundation
import objc_confuse
public class Handler{
    //混淆素材
    public class func executeConfuseAssetsFiles(assetsDirectory path:String?){
        Handler.swift_handleXcassetsFiles(assetsDirectory: path)
    }
    //
    public class func swift_handleXcassetsFiles(assetsDirectory path:String?){
        handleXcassetsFiles(path)
    }
}
