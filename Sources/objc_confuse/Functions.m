//
//  Functions.m
//  
//
//  Created by Mosquito1123 on 27/11/2019.
//

#import "Functions.h"
#if TARGET_OS_OSX
#import <Cocoa/Cocoa.h>
#else
#import <UIKit/UIKit.h>
#endif
#pragma mark - 公共方法


/*
 *  字符串混淆解密函数，将char[] 形式字符数组和 aa异或运算揭秘
 *  如果没有经过混淆，请关闭宏开关
 */
extern char* decryptConstString(char* string)
{
    char* origin_string = string;
    while(*string) {
        *string ^= 0xAA;
        string++;
    }
    return origin_string;
}
static const NSString *kRandomAlphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
NSString *randomString(NSInteger length) {
    NSMutableString *ret = [NSMutableString stringWithCapacity:length];
    for (int i = 0; i < length; i++) {
        [ret appendFormat:@"%C", [kRandomAlphabet characterAtIndex:arc4random_uniform((uint32_t)[kRandomAlphabet length])]];
    }
    return ret;
}

NSString *randomLetter() {
    return [NSString stringWithFormat:@"%C", [kRandomAlphabet characterAtIndex:arc4random_uniform(52)]];
}

NSRange getOutermostCurlyBraceRange(NSString *string, unichar beginChar, unichar endChar, NSInteger beginIndex) {
    NSInteger braceCount = -1;
    NSInteger endIndex = string.length - 1;
    for (NSInteger i = beginIndex; i <= endIndex; i++) {
        unichar c = [string characterAtIndex:i];
        if (c == beginChar) {
            braceCount = ((braceCount == -1) ? 0 : braceCount) + 1;
        } else if (c == endChar) {
            braceCount--;
        }
        if (braceCount == 0) {
            endIndex = i;
            break;
        }
    }
    return NSMakeRange(beginIndex + 1, endIndex - beginIndex - 1);
}

NSString * getSwiftImportString(NSString *string) {
    NSMutableString *ret = [NSMutableString string];
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^ *import *.+" options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *importRow = [string substringWithRange:obj.range];
        [ret appendString:importRow];
        [ret appendString:@"\n"];
    }];
    
    return ret;
}

BOOL regularReplacement(NSMutableString *originalString, NSString *regularExpression, NSString *newString) {
    __block BOOL isChanged = NO;
    BOOL isGroupNo1 = [newString isEqualToString:@"\\1"];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnixLineSeparators error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:originalString options:0 range:NSMakeRange(0, originalString.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!isChanged) {
            isChanged = YES;
        }
        if (isGroupNo1) {
            NSString *withString = [originalString substringWithRange:[obj rangeAtIndex:1]];
            [originalString replaceCharactersInRange:obj.range withString:withString];
        } else {
            [originalString replaceCharactersInRange:obj.range withString:newString];
        }
    }];
    return isChanged;
}

void renameFile(NSString *oldPath, NSString *newPath) {
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
    if (error) {
        printf("修改文件名称失败。\n  oldPath=%s\n  newPath=%s\n  ERROR:%s\n", oldPath.UTF8String, newPath.UTF8String, error.localizedDescription.UTF8String);
        abort();
    }
}
//混淆图片
void confuseImageFile(NSString *oldPath){
    NSData *imageData = [[NSData alloc]initWithContentsOfFile:oldPath];
    double subtraction = 0.1;
    //取绝对值
    subtraction = ABS(subtraction);
    //乘以精度的位数
    subtraction *= 100;
    //在差值间随机
    double randomNumber = arc4random() % ((int) subtraction + 1);
    //随机的结果除以精度的位数
    randomNumber /= 100;
    //将随机的值加到较小的值上
    double result = 0.9 + randomNumber;
    #if TARGET_OS_OSX
    //mac os
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:result] forKey:NSImageGamma];
    NSData *imgDt = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
    [imgDt writeToFile:oldPath atomically:YES];
    
    #else
    //ios
    UIImage *img=[[UIImage alloc]initWithContentsOfFile:oldPath];
    NSData *data = UIImageJPEGRepresentation(img, result);
    [data writeToFile:oldPath atomically:YES];
    #endif
    
}

#pragma mark - 生成垃圾代码

void recursiveDirectory(NSString *directory, NSArray<NSString *> *ignoreDirNames, void(^handleMFile)(NSString *mFilePath), void(^handleSwiftFile)(NSString *swiftFilePath)) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    BOOL isDirectory;
    for (NSString *filePath in files) {
        NSString *path = [directory stringByAppendingPathComponent:filePath];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            if (![ignoreDirNames containsObject:filePath]) {
                recursiveDirectory(path, nil, handleMFile, handleSwiftFile);
            }
            continue;
        }
        NSString *fileName = filePath.lastPathComponent;
        if ([fileName hasSuffix:@".h"]) {
            fileName = [fileName stringByDeletingPathExtension];
            
            NSString *mFileName = [fileName stringByAppendingPathExtension:@"m"];
            if ([files containsObject:mFileName]) {
                handleMFile([directory stringByAppendingPathComponent:mFileName]);
            }
        } else if ([fileName hasSuffix:@".swift"]) {
            handleSwiftFile([directory stringByAppendingPathComponent:fileName]);
        }
    }
}

NSString * getImportString(NSString *hFileContent, NSString *mFileContent) {
    NSMutableString *ret = [NSMutableString string];
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^ *[@#]import *.+" options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:hFileContent options:0 range:NSMakeRange(0, hFileContent.length)];
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *importRow = [hFileContent substringWithRange:[obj rangeAtIndex:0]];
        [ret appendString:importRow];
        [ret appendString:@"\n"];
    }];
    
    matches = [expression matchesInString:mFileContent options:0 range:NSMakeRange(0, mFileContent.length)];
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *importRow = [mFileContent substringWithRange:[obj rangeAtIndex:0]];
        [ret appendString:importRow];
        [ret appendString:@"\n"];
    }];
    
    return ret;
}

static NSString *const kHClassFileTemplate = @"\
%@\n\
@interface %@ (%@)\n\
%@\n\
@end\n";
static NSString *const kMClassFileTemplate = @"\
#import \"%@+%@.h\"\n\
@implementation %@ (%@)\n\
%@\n\
@end\n";
static NSString *const kHNewClassFileTemplate = @"\
#import <Foundation/Foundation.h>\n\
@interface %@: NSObject\n\
%@\n\
@end\n";
static NSString *const kMNewClassFileTemplate = @"\
#import \"%@.h\"\n\
@implementation %@\n\
%@\n\
@end\n";
void generateSpamCodeFile(NSString *outDirectory, NSString *mFilePath, GSCSourceType type, NSMutableString *categoryCallImportString, NSMutableString *categoryCallFuncString, NSMutableString *newClassCallImportString, NSMutableString *newClassCallFuncString) {
    NSString *mFileContent = [NSString stringWithContentsOfFile:mFilePath encoding:NSUTF8StringEncoding error:nil];
    NSString *regexStr;
    switch (type) {
        case GSCSourceTypeClass:
            regexStr = @" *@implementation +(\\w+)[^(]*\\n(?:.|\\n)+?@end";
            break;
        case GSCSourceTypeCategory:
            regexStr = @" *@implementation *(\\w+) *\\((\\w+)\\)(?:.|\\n)+?@end";
            break;
    }
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:mFileContent options:0 range:NSMakeRange(0, mFileContent.length)];
    if (matches.count <= 0) return;
    
    NSString *hFilePath = [mFilePath.stringByDeletingPathExtension stringByAppendingPathExtension:@"h"];
    NSString *hFileContent = [NSString stringWithContentsOfFile:hFilePath encoding:NSUTF8StringEncoding error:nil];
    
    // 准备要引入的文件
    NSString *fileImportStrings = getImportString(hFileContent, mFileContent);
    
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull impResult, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *className = [mFileContent substringWithRange:[impResult rangeAtIndex:1]];
        NSString *categoryName = nil;
        NSString *newClassName = [NSString stringWithFormat:@"%@%@%@", gOutParameterName, className, randomLetter()];
        if (impResult.numberOfRanges >= 3) {
            categoryName = [mFileContent substringWithRange:[impResult rangeAtIndex:2]];
        }
        
        if (type == GSCSourceTypeClass) {
            // 如果该类型没有公开，只在 .m 文件中使用，则不处理
            NSString *regexStr = [NSString stringWithFormat:@"\\b%@\\b", className];
            NSRange range = [hFileContent rangeOfString:regexStr options:NSRegularExpressionSearch];
            if (range.location == NSNotFound) {
                return;
            }
        }

        // 查找方法
        NSString *implementation = [mFileContent substringWithRange:impResult.range];
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"^ *([-+])[^)]+\\)([^;{]+)" options:NSRegularExpressionAnchorsMatchLines|NSRegularExpressionUseUnicodeWordBoundaries error:nil];
        NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:implementation options:0 range:NSMakeRange(0, implementation.length)];
        if (matches.count <= 0) return;
        
        // 新类 h m 垃圾文件内容
        NSMutableString *hNewClassFileMethodsString = [NSMutableString string];
        NSMutableString *mNewClassFileMethodsString = [NSMutableString string];
        
        // 生成 h m 垃圾文件内容
        NSMutableString *hFileMethodsString = [NSMutableString string];
        NSMutableString *mFileMethodsString = [NSMutableString string];
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull matche, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *symbol = @"+";//[implementation substringWithRange:[matche rangeAtIndex:1]];
            NSString *methodName = [[implementation substringWithRange:[matche rangeAtIndex:2]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *newClassMethodName = nil;
            NSString *methodCallName = nil;
            NSString *newClassMethodCallName = nil;
            if ([methodName containsString:@":"]) {
                // 去掉参数，生成无参数的新名称
                NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"\\b([\\w]+) *:" options:0 error:nil];
                NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:methodName options:0 range:NSMakeRange(0, methodName.length)];
                if (matches.count > 0) {
                    NSMutableString *newMethodName = [NSMutableString string];
                    NSMutableString *newClassNewMethodName = [NSMutableString string];
                    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull matche, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *str = [methodName substringWithRange:[matche rangeAtIndex:1]];
                        [newMethodName appendString:(newMethodName.length > 0 ? str.capitalizedString : str)];
                        [newClassNewMethodName appendFormat:@"%@%@", randomLetter(), str.capitalizedString];
                    }];
                    methodCallName = [NSString stringWithFormat:@"%@%@", newMethodName, gOutParameterName.capitalizedString];
                    [newMethodName appendFormat:@"%@:(NSInteger)%@", gOutParameterName.capitalizedString, gOutParameterName];
                    methodName = newMethodName;
                    
                    newClassMethodCallName = [NSString stringWithFormat:@"%@", newClassNewMethodName];
                    newClassMethodName = [NSString stringWithFormat:@"%@:(NSInteger)%@", newClassMethodCallName, gOutParameterName];
                } else {
                    methodName = [methodName stringByAppendingFormat:@" %@:(NSInteger)%@", gOutParameterName, gOutParameterName];
                }
            } else {
                newClassMethodCallName = [NSString stringWithFormat:@"%@%@", randomLetter(), methodName];
                newClassMethodName = [NSString stringWithFormat:@"%@:(NSInteger)%@", newClassMethodCallName, gOutParameterName];
                
                methodCallName = [NSString stringWithFormat:@"%@%@", methodName, gOutParameterName.capitalizedString];
                methodName = [methodName stringByAppendingFormat:@"%@:(NSInteger)%@", gOutParameterName.capitalizedString, gOutParameterName];
            }
            
            [hFileMethodsString appendFormat:@"%@ (BOOL)%@;\n", symbol, methodName];
            
            [mFileMethodsString appendFormat:@"%@ (BOOL)%@ {\n", symbol, methodName];
            [mFileMethodsString appendFormat:@"    return %@ %% %u == 0;\n", gOutParameterName, arc4random_uniform(50) + 1];
            [mFileMethodsString appendString:@"}\n"];
            
            if (methodCallName.length > 0) {
                if (gSpamCodeFuncationCallName && categoryCallFuncString.length <= 0) {
                    [categoryCallFuncString appendFormat:@"static inline NSInteger %@() {\nNSInteger ret = 0;\n", gSpamCodeFuncationCallName];
                }
                [categoryCallFuncString appendFormat:@"ret += [%@ %@:%u] ? 1 : 0;\n", className, methodCallName, arc4random_uniform(100)];
            }
            
            
            if (newClassMethodName.length > 0) {
                [hNewClassFileMethodsString appendFormat:@"%@ (BOOL)%@;\n", symbol, newClassMethodName];
                
                [mNewClassFileMethodsString appendFormat:@"%@ (BOOL)%@ {\n", symbol, newClassMethodName];
                [mNewClassFileMethodsString appendFormat:@"    return %@ %% %u == 0;\n", gOutParameterName, arc4random_uniform(50) + 1];
                [mNewClassFileMethodsString appendString:@"}\n"];
            }
            
            if (newClassMethodCallName.length > 0) {
                if (gNewClassFuncationCallName && newClassCallFuncString.length <= 0) {
                    [newClassCallFuncString appendFormat:@"static inline NSInteger %@() {\nNSInteger ret = 0;\n", gNewClassFuncationCallName];
                }
                [newClassCallFuncString appendFormat:@"ret += [%@ %@:%u] ? 1 : 0;\n", newClassName, newClassMethodCallName, arc4random_uniform(100)];
            }
        }];
        
        NSString *newCategoryName;
        switch (type) {
            case GSCSourceTypeClass:
                newCategoryName = gOutParameterName.capitalizedString;
                break;
            case GSCSourceTypeCategory:
                newCategoryName = [NSString stringWithFormat:@"%@%@", categoryName, gOutParameterName.capitalizedString];
                break;
        }
        
        // category m
        NSString *fileName = [NSString stringWithFormat:@"%@+%@.m", className, newCategoryName];
        NSString *fileContent = [NSString stringWithFormat:kMClassFileTemplate, className, newCategoryName, className, newCategoryName, mFileMethodsString];
        [fileContent writeToFile:[outDirectory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        // category h
        fileName = [NSString stringWithFormat:@"%@+%@.h", className, newCategoryName];
        fileContent = [NSString stringWithFormat:kHClassFileTemplate, fileImportStrings, className, newCategoryName, hFileMethodsString];
        [fileContent writeToFile:[outDirectory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        [categoryCallImportString appendFormat:@"#import \"%@\"\n", fileName];
        
        // new class m
        NSString *newOutDirectory = [outDirectory stringByAppendingPathComponent:kNewClassDirName];
        fileName = [NSString stringWithFormat:@"%@.m", newClassName];
        fileContent = [NSString stringWithFormat:kMNewClassFileTemplate, newClassName, newClassName, mNewClassFileMethodsString];
        [fileContent writeToFile:[newOutDirectory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        // new class h
        fileName = [NSString stringWithFormat:@"%@.h", newClassName];
        fileContent = [NSString stringWithFormat:kHNewClassFileTemplate, newClassName, hNewClassFileMethodsString];
        [fileContent writeToFile:[newOutDirectory stringByAppendingPathComponent:fileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        [newClassCallImportString appendFormat:@"#import \"%@\"\n", fileName];
    }];
}

static NSString *const kSwiftFileTemplate = @"\
%@\n\
extension %@ {\n%@\
}\n";
static NSString *const kSwiftMethodTemplate = @"\
    func %@%@(_ %@: String%@) {\n\
        print(%@)\n\
    }\n";
void generateSwiftSpamCodeFile(NSString *outDirectory, NSString *swiftFilePath) {
    NSString *swiftFileContent = [NSString stringWithContentsOfFile:swiftFilePath encoding:NSUTF8StringEncoding error:nil];
    
    // 查找 class 声明
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@" *(class|struct) +(\\w+)[^{]+" options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:swiftFileContent options:0 range:NSMakeRange(0, swiftFileContent.length)];
    if (matches.count <= 0) return;
    
    NSString *fileImportStrings = getSwiftImportString(swiftFileContent);
    __block NSInteger braceEndIndex = 0;
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull classResult, NSUInteger idx, BOOL * _Nonnull stop) {
        // 已经处理到该 range 后面去了，过掉
        NSInteger matchEndIndex = classResult.range.location + classResult.range.length;
        if (matchEndIndex < braceEndIndex) return;
        // 是 class 方法，过掉
        NSString *fullMatchString = [swiftFileContent substringWithRange:classResult.range];
        if ([fullMatchString containsString:@"("]) return;
        
        NSRange braceRange = getOutermostCurlyBraceRange(swiftFileContent, '{', '}', matchEndIndex);
        braceEndIndex = braceRange.location + braceRange.length;
        
        // 查找方法
        NSString *classContent = [swiftFileContent substringWithRange:braceRange];
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"func +([^(]+)\\([^{]+" options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
        NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:classContent options:0 range:NSMakeRange(0, classContent.length)];
        if (matches.count <= 0) return;
        
        NSMutableString *methodsString = [NSMutableString string];
        [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull funcResult, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange funcNameRange = [funcResult rangeAtIndex:1];
            NSString *funcName = [classContent substringWithRange:funcNameRange];
            NSRange oldParameterRange = getOutermostCurlyBraceRange(classContent, '(', ')', funcNameRange.location + funcNameRange.length);
            NSString *oldParameterName = [classContent substringWithRange:oldParameterRange];
            oldParameterName = [oldParameterName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (oldParameterName.length > 0) {
                oldParameterName = [@", " stringByAppendingString:oldParameterName];
            }
            if (![funcName containsString:@"<"] && ![funcName containsString:@">"]) {
                funcName = [NSString stringWithFormat:@"%@%@", funcName, randomString(5)];
                [methodsString appendFormat:kSwiftMethodTemplate, funcName, gOutParameterName.capitalizedString, gOutParameterName, oldParameterName, gOutParameterName];
            } else {
                NSLog(@"string contains `[` or `]` bla! funcName: %@", funcName);
            }
        }];
        if (methodsString.length <= 0) return;
        
        NSString *className = [swiftFileContent substringWithRange:[classResult rangeAtIndex:2]];
        
        NSString *fileName = [NSString stringWithFormat:@"%@%@Ext.swift", className, gOutParameterName.capitalizedString];
        NSString *filePath = [outDirectory stringByAppendingPathComponent:fileName];
        NSString *fileContent = @"";
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        }
        fileContent = [fileContent stringByAppendingFormat:kSwiftFileTemplate, fileImportStrings, className, methodsString];
        [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }];
}

#pragma mark - 处理 Xcassets 中的图片文件

void handleXcassetsFiles(NSString *directory) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    BOOL isDirectory;
    for (NSString *fileName in files) {
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:filePath isDirectory:&isDirectory] && isDirectory) {
            handleXcassetsFiles(filePath);
            continue;
        }
        if (![fileName isEqualToString:@"Contents.json"]) continue;
        NSString *contentsDirectoryName = filePath.stringByDeletingLastPathComponent.lastPathComponent;
        if (![contentsDirectoryName hasSuffix:@".imageset"]) continue;
        
        NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (!fileContent) continue;
        
        NSMutableArray<NSString *> *processedImageFileNameArray = @[].mutableCopy;
        static NSString * const regexStr = @"\"filename\" *: *\"(.*)?\"";
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionUseUnicodeWordBoundaries error:nil];
        NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
        while (matches.count > 0) {
            NSInteger i = 0;
            NSString *imageFileName = nil;
            do {
                if (i >= matches.count) {
                    i = -1;
                    break;
                }
                imageFileName = [fileContent substringWithRange:[matches[i] rangeAtIndex:1]];
                i++;
            } while ([processedImageFileNameArray containsObject:imageFileName]);
            if (i < 0) break;
            
            NSString *imageFilePath = [filePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:imageFileName];
            if ([fm fileExistsAtPath:imageFilePath]) {
                NSString *newImageFileName = [randomString(10) stringByAppendingPathExtension:imageFileName.pathExtension];
                NSString *newImageFilePath = [filePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:newImageFileName];
                while ([fm fileExistsAtPath:newImageFileName]) {
                    newImageFileName = [randomString(10) stringByAppendingPathExtension:imageFileName.pathExtension];
                    newImageFilePath = [filePath.stringByDeletingLastPathComponent stringByAppendingPathComponent:newImageFileName];
                }
                confuseImageFile(imageFilePath);
                renameFile(imageFilePath, newImageFilePath);
                
                fileContent = [fileContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"\"%@\"", imageFileName]
                                                                     withString:[NSString stringWithFormat:@"\"%@\"", newImageFileName]];
                [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                [processedImageFileNameArray addObject:newImageFileName];
            } else {
                [processedImageFileNameArray addObject:imageFileName];
            }
            
            matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
        }
    }
}

#pragma mark - 删除注释

void deleteComments(NSString *directory, NSArray<NSString *> *ignoreDirNames) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    BOOL isDirectory;
    for (NSString *fileName in files) {
        if ([ignoreDirNames containsObject:fileName]) continue;
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:filePath isDirectory:&isDirectory] && isDirectory) {
            deleteComments(filePath, ignoreDirNames);
            continue;
        }
        if (![fileName hasSuffix:@".h"] && ![fileName hasSuffix:@".m"] && ![fileName hasSuffix:@".mm"] && ![fileName hasSuffix:@".swift"]) continue;
        NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        regularReplacement(fileContent, @"([^:/])//.*",             @"\\1");
        regularReplacement(fileContent, @"^//.*",                   @"");
        regularReplacement(fileContent, @"/\\*{1,2}[\\s\\S]*?\\*/", @"");
        regularReplacement(fileContent, @"^\\s*\\n",                @"");
        [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

#pragma mark - 修改工程名

void resetEntitlementsFileName(NSString *projectPbxprojFilePath, NSString *oldName, NSString *newName) {
    NSString *rootPath = projectPbxprojFilePath.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:projectPbxprojFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = @"CODE_SIGN_ENTITLEMENTS = \"?([^\";]+)";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *entitlementsPath = [fileContent substringWithRange:[obj rangeAtIndex:1]];
        NSString *entitlementsName = entitlementsPath.lastPathComponent.stringByDeletingPathExtension;
        if (![entitlementsName isEqualToString:oldName]) return;
        entitlementsPath = [rootPath stringByAppendingPathComponent:entitlementsPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:entitlementsPath]) return;
        NSString *newPath = [entitlementsPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[newName stringByAppendingPathExtension:@"entitlements"]];
        renameFile(entitlementsPath, newPath);
    }];
}

void resetBridgingHeaderFileName(NSString *projectPbxprojFilePath, NSString *oldName, NSString *newName) {
    NSString *rootPath = projectPbxprojFilePath.stringByDeletingLastPathComponent.stringByDeletingLastPathComponent;
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:projectPbxprojFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = @"SWIFT_OBJC_BRIDGING_HEADER = \"?([^\";]+)";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *entitlementsPath = [fileContent substringWithRange:[obj rangeAtIndex:1]];
        NSString *entitlementsName = entitlementsPath.lastPathComponent.stringByDeletingPathExtension;
        if (![entitlementsName isEqualToString:oldName]) return;
        entitlementsPath = [rootPath stringByAppendingPathComponent:entitlementsPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:entitlementsPath]) return;
        NSString *newPath = [entitlementsPath.stringByDeletingLastPathComponent stringByAppendingPathComponent:[newName stringByAppendingPathExtension:@"h"]];
        renameFile(entitlementsPath, newPath);
    }];
}

void replacePodfileContent(NSString *filePath, NSString *oldString, NSString *newString) {
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = [NSString stringWithFormat:@"target +'%@", oldString];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileContent replaceCharactersInRange:obj.range withString:[NSString stringWithFormat:@"target '%@", newString]];
    }];
    
    regularExpression = [NSString stringWithFormat:@"project +'%@.", oldString];
    expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileContent replaceCharactersInRange:obj.range withString:[NSString stringWithFormat:@"project '%@.", newString]];
    }];
    
    [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

void replaceProjectFileContent(NSString *filePath, NSString *oldString, NSString *newString) {
    NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *regularExpression = [NSString stringWithFormat:@"\\b%@\\b", oldString];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regularExpression options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [expression matchesInString:fileContent options:0 range:NSMakeRange(0, fileContent.length)];
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [fileContent replaceCharactersInRange:obj.range withString:newString];
    }];
    
    [fileContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

void modifyFilesClassName(NSString *sourceCodeDir, NSString *oldClassName, NSString *newClassName);

void modifyProjectName(NSString *projectDir, NSString *oldName, NSString *newName) {
    NSString *sourceCodeDirPath = [projectDir stringByAppendingPathComponent:oldName];
    NSString *xcodeprojFilePath = [sourceCodeDirPath stringByAppendingPathExtension:@"xcodeproj"];
    NSString *xcworkspaceFilePath = [sourceCodeDirPath stringByAppendingPathExtension:@"xcworkspace"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    
    // old-Swift.h > new-Swift.h
    modifyFilesClassName(projectDir, [oldName stringByAppendingString:@"-Swift.h"], [newName stringByAppendingString:@"-Swift.h"]);
    
    // 改 Podfile 中的工程名
    NSString *podfilePath = [projectDir stringByAppendingPathComponent:@"Podfile"];
    if ([fm fileExistsAtPath:podfilePath isDirectory:&isDirectory] && !isDirectory) {
        replacePodfileContent(podfilePath, oldName, newName);
    }
    
    // 改工程文件内容
    if ([fm fileExistsAtPath:xcodeprojFilePath isDirectory:&isDirectory] && isDirectory) {
        // 替换 project.pbxproj 文件内容
        NSString *projectPbxprojFilePath = [xcodeprojFilePath stringByAppendingPathComponent:@"project.pbxproj"];
        if ([fm fileExistsAtPath:projectPbxprojFilePath]) {
            resetBridgingHeaderFileName(projectPbxprojFilePath, [oldName stringByAppendingString:@"-Bridging-Header"], [newName stringByAppendingString:@"-Bridging-Header"]);
            resetEntitlementsFileName(projectPbxprojFilePath, oldName, newName);
            replaceProjectFileContent(projectPbxprojFilePath, oldName, newName);
        }
        // 替换 project.xcworkspace/contents.xcworkspacedata 文件内容
        NSString *contentsXcworkspacedataFilePath = [xcodeprojFilePath stringByAppendingPathComponent:@"project.xcworkspace/contents.xcworkspacedata"];
        if ([fm fileExistsAtPath:contentsXcworkspacedataFilePath]) {
            replaceProjectFileContent(contentsXcworkspacedataFilePath, oldName, newName);
        }
        // xcuserdata 本地用户文件
        NSString *xcuserdataFilePath = [xcodeprojFilePath stringByAppendingPathComponent:@"xcuserdata"];
        if ([fm fileExistsAtPath:xcuserdataFilePath]) {
            [fm removeItemAtPath:xcuserdataFilePath error:nil];
        }
        // 改名工程文件
        renameFile(xcodeprojFilePath, [[projectDir stringByAppendingPathComponent:newName] stringByAppendingPathExtension:@"xcodeproj"]);
    }
    
    // 改工程组文件内容
    if ([fm fileExistsAtPath:xcworkspaceFilePath isDirectory:&isDirectory] && isDirectory) {
        // 替换 contents.xcworkspacedata 文件内容
        NSString *contentsXcworkspacedataFilePath = [xcworkspaceFilePath stringByAppendingPathComponent:@"contents.xcworkspacedata"];
        if ([fm fileExistsAtPath:contentsXcworkspacedataFilePath]) {
            replaceProjectFileContent(contentsXcworkspacedataFilePath, oldName, newName);
        }
        // xcuserdata 本地用户文件
        NSString *xcuserdataFilePath = [xcworkspaceFilePath stringByAppendingPathComponent:@"xcuserdata"];
        if ([fm fileExistsAtPath:xcuserdataFilePath]) {
            [fm removeItemAtPath:xcuserdataFilePath error:nil];
        }
        // 改名工程文件
        renameFile(xcworkspaceFilePath, [[projectDir stringByAppendingPathComponent:newName] stringByAppendingPathExtension:@"xcworkspace"]);
    }
    
    // 改源代码文件夹名称
    if ([fm fileExistsAtPath:sourceCodeDirPath isDirectory:&isDirectory] && isDirectory) {
        renameFile(sourceCodeDirPath, [projectDir stringByAppendingPathComponent:newName]);
    }
}

#pragma mark - 修改类名前缀

void modifyFilesClassName(NSString *sourceCodeDir, NSString *oldClassName, NSString *newClassName) {
    // 文件内容 Const > DDConst (h,m,swift,xib,storyboard)
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:sourceCodeDir error:nil];
    BOOL isDirectory;
    for (NSString *filePath in files) {
        NSString *path = [sourceCodeDir stringByAppendingPathComponent:filePath];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            modifyFilesClassName(path, oldClassName, newClassName);
            continue;
        }
        
        NSString *fileName = filePath.lastPathComponent;
        if ([fileName hasSuffix:@".h"] || [fileName hasSuffix:@".m"] || [fileName hasSuffix:@".pch"] || [fileName hasSuffix:@".swift"] || [fileName hasSuffix:@".xib"] || [fileName hasSuffix:@".storyboard"]) {
            
            NSError *error = nil;
            NSMutableString *fileContent = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                printf("打开文件 %s 失败：%s\n", path.UTF8String, error.localizedDescription.UTF8String);
                abort();
            }
            
            NSString *regularExpression = [NSString stringWithFormat:@"\\b%@\\b", oldClassName];
            BOOL isChanged = regularReplacement(fileContent, regularExpression, newClassName);
            if (!isChanged) continue;
            error = nil;
            [fileContent writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) {
                printf("保存文件 %s 失败：%s\n", path.UTF8String, error.localizedDescription.UTF8String);
                abort();
            }
        }
    }
}

void modifyClassNamePrefix(NSMutableString *projectContent, NSString *sourceCodeDir, NSArray<NSString *> *ignoreDirNames, NSString *oldName, NSString *newName) {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // 遍历源代码文件 h 与 m 配对，swift
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:sourceCodeDir error:nil];
    BOOL isDirectory;
    for (NSString *filePath in files) {
        NSString *path = [sourceCodeDir stringByAppendingPathComponent:filePath];
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            if (![ignoreDirNames containsObject:filePath]) {
                modifyClassNamePrefix(projectContent, path, ignoreDirNames, oldName, newName);
            }
            continue;
        }
        
        NSString *fileName = filePath.lastPathComponent.stringByDeletingPathExtension;
        NSString *fileExtension = filePath.pathExtension;
        NSString *newClassName;
        if ([fileName hasPrefix:oldName]) {
            newClassName = [newName stringByAppendingString:[fileName substringFromIndex:oldName.length]];
        } else {
            //处理是category的情况。当是category时，修改+号后面的类名前缀
            NSString *oldNamePlus = [NSString stringWithFormat:@"+%@",oldName];
            if ([fileName containsString:oldNamePlus]) {
                NSMutableString *fileNameStr = [[NSMutableString alloc] initWithString:fileName];
                [fileNameStr replaceCharactersInRange:[fileName rangeOfString:oldNamePlus] withString:[NSString stringWithFormat:@"+%@",newName]];
                newClassName = fileNameStr;
            }else{
                newClassName = [newName stringByAppendingString:fileName];
            }
        }
        
        // 文件名 Const.ext > DDConst.ext
        if ([fileExtension isEqualToString:@"h"]) {
            NSString *mFileName = [fileName stringByAppendingPathExtension:@"m"];
            if ([files containsObject:mFileName]) {
                NSString *oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"h"];
                NSString *newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"h"];
                renameFile(oldFilePath, newFilePath);
                oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"m"];
                newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"m"];
                renameFile(oldFilePath, newFilePath);
                oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"xib"];
                if ([fm fileExistsAtPath:oldFilePath]) {
                    newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"xib"];
                    renameFile(oldFilePath, newFilePath);
                }
                
                @autoreleasepool {
                    modifyFilesClassName(gSourceCodeDir, fileName, newClassName);
                }
            } else {
                continue;
            }
        } else if ([fileExtension isEqualToString:@"swift"]) {
            NSString *oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"swift"];
            NSString *newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"swift"];
            renameFile(oldFilePath, newFilePath);
            oldFilePath = [[sourceCodeDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"xib"];
            if ([fm fileExistsAtPath:oldFilePath]) {
                newFilePath = [[sourceCodeDir stringByAppendingPathComponent:newClassName] stringByAppendingPathExtension:@"xib"];
                renameFile(oldFilePath, newFilePath);
            }
            
            @autoreleasepool {
                modifyFilesClassName(gSourceCodeDir, fileName.stringByDeletingPathExtension, newClassName);
            }
        } else {
            continue;
        }
        
        // 修改工程文件中的文件名
        NSString *regularExpression = [NSString stringWithFormat:@"\\b%@\\b", fileName];
        regularReplacement(projectContent, regularExpression, newClassName);
    }
}
@implementation Functions

@end
