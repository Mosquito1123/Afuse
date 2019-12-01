//
//  File.swift
//  
//
//  Created by Mosquito1123 on 30/11/2019.
//

import Foundation
public class AutoConfuse{
    //自动混淆
    public class func auto_confuse(inputDir input:String?,needHandlerAssets handleAssets:Bool=true,needDeleteComments:Bool=true,modifyProjectName modifyProjectNameParams:String?,modifyClassNamePrefix modifyClassNamePrefixParams:String?,ignoreDirNames dirNamesString:String?){
        
        let ignoreDirNames = dirNamesString?.components(separatedBy: ",") ?? []
        print("IgnoreDir names are \(ignoreDirNames)")



        let input = Recursiver.validInput(input)
        Recursiver.swift_recursiveDirectory(directory: input ?? "", ignoreDirNames: ignoreDirNames, handleMFile: { (mFilePath) in
            print(mFilePath ?? "")
        }) { (swiftFilePath) in
            print(swiftFilePath ?? "")
        }
        Handler.executeConfuseAssetsFiles(assetsDirectory: input)
        Deletion.executeDeleteComment(directoryPath: input, ignoreDirNames: ignoreDirNames)
        Modification.executeModifyProjectName(input,modifyProjectNameParams)
        Modification.executeModifyClassNamePrefix(input,ignoreDirNames,modifyClassNamePrefixParams)
    }
}
