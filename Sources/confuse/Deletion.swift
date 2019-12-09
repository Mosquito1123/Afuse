//
//  File.swift
//  
//
//  Created by Mosquito1123 on 27/11/2019.
//

import Foundation
import objc_confuse



public class Deletion{

    //deleteComments
    public class func executeDeleteComment(directoryPath path:String?,ignoreDirNames array:[String]?){
        Deletion.swift_deleteComments(directoryPath: path, ignoreDirNames: array)
    }
    //deleteComments
    public class func swift_deleteComments(directoryPath path:String?,ignoreDirNames array:[String]?){
           deleteComments(path, array)
    }
}
