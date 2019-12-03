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



        Preparation.shared.prepare_to_confuse(input)
        Preparation.shared.prepare_to_decode_confuse(input)
            
        Preparation.shared.prepare_des_confuse_and_decode_confuse(input)
        Confusion.confuse()
        let input = Recursiver.validInput(input)
        
        Recursiver.swift_recursiveDirectory(directory: input ?? "", ignoreDirNames: ignoreDirNames, handleMFile: { (mFilePath) in

            if mFilePath?.contains("Tortoise") == true{
                Modification.replaceHeader(mFilePath)
            }
        }) { (swiftFilePath) in
            print(swiftFilePath ?? "")
        }
        if handleAssets == true{
            Handler.executeConfuseAssetsFiles(assetsDirectory: input)

        }
        if needDeleteComments == true{
            Deletion.executeDeleteComment(directoryPath: input, ignoreDirNames: ignoreDirNames)

        }
        Modification.executeModifyProjectName(input,modifyProjectNameParams)
        Modification.executeModifyClassNamePrefix(input,ignoreDirNames,modifyClassNamePrefixParams)
    }
}
