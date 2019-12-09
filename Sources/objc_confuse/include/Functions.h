//
//  Functions.h
//  
//
//  Created by Mosquito1123 on 27/11/2019.
//

#import <Foundation/Foundation.h>
#include <stdlib.h>

typedef NS_ENUM(NSInteger, GSCSourceType) {
    GSCSourceTypeClass,
    GSCSourceTypeCategory,
};


extern char* decryptConstString(char* string);
void recursiveDirectory(NSString *directory, NSArray<NSString *> *ignoreDirNames, void(^handleMFile)(NSString *mFilePath), void(^handleSwiftFile)(NSString *swiftFilePath));
void generateSpamCodeFile(NSString *outDirectory, NSString *mFilePath, GSCSourceType type, NSMutableString *categoryCallImportString, NSMutableString *categoryCallFuncString, NSMutableString *newClassCallImportString, NSMutableString *newClassCallFuncString);
void generateSwiftSpamCodeFile(NSString *outDirectory, NSString *swiftFilePath);
NSString *randomString(NSInteger length);
void handleXcassetsFiles(NSString *directory);
void deleteComments(NSString *directory, NSArray<NSString *> *ignoreDirNames);
void modifyProjectName(NSString *projectDir, NSString *oldName, NSString *newName);
void modifyClassNamePrefix(NSMutableString *projectContent, NSString *sourceCodeDir, NSArray<NSString *> *ignoreDirNames, NSString *oldName, NSString *newName);

NSString *gOutParameterName = nil;
NSString *gSpamCodeFuncationCallName = nil;
NSString *gNewClassFuncationCallName = nil;
NSString *gSourceCodeDir = nil;
static NSString * const kNewClassDirName = @"NewClass";
NS_ASSUME_NONNULL_BEGIN


NS_ASSUME_NONNULL_END
