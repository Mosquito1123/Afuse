//
//  File.swift
//  
//
//  Created by Mosquito1123 on 03/12/2019.
//

import Foundation


public struct Template{
    public static let des_confuse_define = """
    #import <Foundation/Foundation.h>
    #import "DES3EncryptUtil.h"
    #define des_decrypt(a)  [DES3EncryptUtil decrypt:[DES3EncryptUtil encrypt:a]];
    #define des_decrypt(b)  [DES3EncryptUtil encrypt:[DES3EncryptUtil decrypt:b]];
"""
    
    public static func des_h()->String{
        return """
        #import <Foundation/Foundation.h>
        @interface DES3EncryptUtil : NSObject
        // 加密方法
        + (NSString*)encrypt:(NSString*)plainText;
        // 解密方法
        + (NSString*)decrypt:(NSString*)encryptText;
        @end
        """
    }
    public static func des_m(_ salt:String="123456",_ iv:String="01234567")->String{
        return """
        #import "DES3EncryptUtil.h"
        #import <Foundation/Foundation.h>
        #import <CommonCrypto/CommonCryptor.h>
        #import "MyBase64.h"

        //秘钥
        #define gkey            @"\(salt)"
        //向量
        #define gIv             @"\(iv)"

        @implementation DES3EncryptUtil : NSObject

        // 加密方法
        + (NSString*)encrypt:(NSString*)plainText {
            NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
            size_t plainTextBufferSize = [data length];
            const void *vplainText = (const void *)[data bytes];
            
            CCCryptorStatus ccStatus;
            uint8_t *bufferPtr = NULL;
            size_t bufferPtrSize = 0;
            size_t movedBytes = 0;
            
            bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
            bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
            memset((void *)bufferPtr, 0x0, bufferPtrSize);
            
            const void *vkey = (const void *) [gkey UTF8String];
            const void *vinitVec = (const void *) [gIv UTF8String];
            
            ccStatus = CCCrypt(kCCEncrypt,
                               kCCAlgorithm3DES,
                               kCCOptionPKCS7Padding,
                               vkey,
                               kCCKeySize3DES,
                               vinitVec,
                               vplainText,
                               plainTextBufferSize,
                               (void *)bufferPtr,
                               bufferPtrSize,
                               &movedBytes);
            
            NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
            NSString *result = [MyBase64 base64EncodedStringFrom:myData];
            return result;
        }

        // 解密方法
        + (NSString*)decrypt:(NSString*)encryptText {
            NSData *encryptData = [MyBase64 dataWithBase64EncodedString:encryptText];
            size_t plainTextBufferSize = [encryptData length];
            const void *vplainText = [encryptData bytes];
            
            CCCryptorStatus ccStatus;
            uint8_t *bufferPtr = NULL;
            size_t bufferPtrSize = 0;
            size_t movedBytes = 0;
            
            bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
            bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
            memset((void *)bufferPtr, 0x0, bufferPtrSize);
            
            const void *vkey = (const void *) [gkey UTF8String];
            const void *vinitVec = (const void *) [gIv UTF8String];
            
            ccStatus = CCCrypt(kCCDecrypt,
                               kCCAlgorithm3DES,
                               kCCOptionPKCS7Padding,
                               vkey,
                               kCCKeySize3DES,
                               vinitVec,
                               vplainText,
                               plainTextBufferSize,
                               (void *)bufferPtr,
                               bufferPtrSize,
                               &movedBytes);
            
            NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                                             length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding] ;
            return result;
        }

        @end
        """
    }
  
    public static let base64_h = """
    #import <Foundation/Foundation.h>

    #define __BASE64( text )        [CommonFunc base64StringFromText:text]
    #define __TEXT( base64 )        [CommonFunc textFromBase64String:base64]

    @interface MyBase64 : NSObject

    /******************************************************************************
    函数名称 : + (NSString *)base64StringFromText:(NSString *)text
    函数描述 : 将文本转换为base64格式字符串
    输入参数 : (NSString *)text    文本
    输出参数 : N/A
    返回参数 : (NSString *)    base64格式字符串
    备注信息 :
    ******************************************************************************/
    + (NSString *)base64StringFromText:(NSString *)text;

    /******************************************************************************
    函数名称 : + (NSString *)base64StringFromText:(NSString *)text
    函数描述 : 将文本转换为base64格式字符串
    输入参数 : (NSString *)text    文本
    输出参数 : N/A
    返回参数 : (NSString *)    base64格式字符串
    备注信息 :
    ******************************************************************************/
    + (NSString *)base64EncodedStringFrom:(NSData *)data;

    /******************************************************************************
    函数名称 : + (NSString *)textFromBase64String:(NSString *)base64
    函数描述 : 将base64格式字符串转换为文本
    输入参数 : (NSString *)base64  base64格式字符串
    输出参数 : N/A
    返回参数 : (NSString *)    文本
    备注信息 :
    ******************************************************************************/
    + (NSString *)textFromBase64String:(NSString *)base64;

    /******************************************************************************
    函数名称 : + (NSString *)textFromBase64String:(NSString *)base64
    函数描述 : 将base64格式字符串转换为文本
    输入参数 : (NSString *)base64  base64格式字符串
    输出参数 : N/A
    返回参数 : (NSString *)    文本
    备注信息 :
    ******************************************************************************/
    + (NSData *)dataWithBase64EncodedString:(NSString *)string;

    @end
    """
    public static let base64_m = """
#import "MyBase64.h"

//引入IOS自带密码库
#import <CommonCrypto/CommonCryptor.h>

//空字符串
#define LocalStr_None   @""

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation MyBase64 : NSObject

+ (NSString *)base64StringFromText:(NSString *)text
{
    if (text && ![text isEqualToString:LocalStr_None]) {
        //取项目的bundleIdentifier作为KEY  改动了此处
        //NSString *key = [[NSBundle mainBundle] bundleIdentifier];
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        //IOS 自带DES加密 Begin  改动了此处
        //data = [self DESEncrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [self base64EncodedStringFrom:data];
    }
    else {
        return LocalStr_None;
    }
}

+ (NSString *)textFromBase64String:(NSString *)base64
{
    if (base64 && ![base64 isEqualToString:LocalStr_None]) {
        //取项目的bundleIdentifier作为KEY   改动了此处
        //NSString *key = [[NSBundle mainBundle] bundleIdentifier];
        NSData *data = [self dataWithBase64EncodedString:base64];
        //IOS 自带DES解密 Begin    改动了此处
        //data = [self DESDecrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else {
        return LocalStr_None;
    }
}

/******************************************************************************
函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
函数描述 : 文本数据进行DES加密
输入参数 : (NSData *)data
(NSString *)key
输出参数 : N/A
返回参数 : (NSData *)
备注信息 : 此函数不可用于过长文本
******************************************************************************/
+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

/******************************************************************************
函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
函数描述 : 文本数据进行DES解密
输入参数 : (NSData *)data
(NSString *)key
输出参数 : N/A
返回参数 : (NSData *)
备注信息 : 此函数不可用于过长文本
******************************************************************************/
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

/******************************************************************************
函数名称 : + (NSData *)dataWithBase64EncodedString:(NSString *)string
函数描述 : base64格式字符串转换为文本数据
输入参数 : (NSString *)string
输出参数 : N/A
返回参数 : (NSData *)
备注信息 :
******************************************************************************/
+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
    if (string == nil)
        [NSException raise:NSInvalidArgumentException format:nil];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

/******************************************************************************
函数名称 : + (NSString *)base64EncodedStringFrom:(NSData *)data
函数描述 : 文本数据转换为base64格式字符串
输入参数 : (NSData *)data
输出参数 : N/A
返回参数 : (NSString *)
备注信息 :
******************************************************************************/
+ (NSString *)base64EncodedStringFrom:(NSData *)data
{
    if ([data length] == 0)
        return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

@end
"""

    public static let tortoiseStructure = """
{
    
    "array": [
        {
            "className": "EgretManager",
            "confuseStrings": ["stable_url","hall","stable","/game/config/version.json"],
            "confuseRegexs": ["https://","wss://","http://","ws://"]
        },
        {
            "className": "EgretViewController",
            "confuseStrings": ["get_app_info","initialized","openinstall_data","set_key","statistic_user_action","download","quit","reload","open_web","close_web","copy_to_clipboard","composite_bitmap","share","save_bitmap_to_gallery","qq_temporary_session","open_site","open_app","ios_app_exists","auth","get_error_version","set_start_path","network_status","offline","delete_auth"],
            "confuseRegexs": ["https://","wss://","http://","ws://"]
        },
        {
            "className": "Limbs",
            "confuseStrings": ["FULL_COMMON_SERVER","com.jiujiuceshi.test","uniqueId","platform","buildVersionCode"],
            "confuseRegexs": ["https://","wss://","http://","ws://"]
        }
    ]
}
"""
    public static let importFoundationString = """
#import <Foundation/Foundation.h>
"""
    public static let headerString = """
    extern char* decryptConstString(char* string);
    """
    public static let  mString = """
    extern char* decryptConstString(char* string)
            {
                char* origin_string = string;
                while(*string) {
                    *string ^= 0xAA;
                    string++;
                }
                return origin_string;
            }
    """
    
    public static let macrodefinition = """
    //字符串混淆加密 和 解密的宏开关
            //#define ggh_confusion
            #ifdef ggh_confusion
                #define confusion_NSSTRING(string) [NSString stringWithUTF8String:decryptConstString(string)]
                #define confusion_CSTRING(string) decryptConstString(string)
            #else
                #define confusion_NSSTRING(string) @string
                #define confusion_CSTRING(string) string
            #endif
    """
    public static func confusion(_ dirPath:String="")->String{
        return """
        #!/usr/bin/env python
        # encoding=utf8
        # -*- coding: utf-8 -*-
        # 本脚本用于对源代码中的字符串进行加密
        # 替换所有字符串常量为加密的char数组，形式((char[]){1, 2, 3, 0})

        import importlib
        import os
        import re
        import sys


        # 替换字符串为((char[]){1, 2, 3, 0})的形式，同时让每个字节与0xAA异或进行加密
        def replace(match):
            string = match.group(2) + '\\x00'
            replaced_string = '((char []) {' + ', '.join(["%i" % ((ord(c) ^ 0xAA) if c != '\0' else 0) for c in list(string)]) + '})'
            return match.group(1) + replaced_string + match.group(3)


        # 修改源代码，加入字符串加密的函数
        def obfuscate(file):
            with open(file, 'r') as f:
                code = f.read()
                f.close()
                code = re.sub(r'(confusion_NSSTRING\\(|confusion_CSTRING\\()"(.*?)"(\\))', replace, code)
                code = re.sub(r'//#define ggh_confusion', '#define ggh_confusion', code)
                with open(file, 'w') as f:
                    f.write(code)
                    f.close()


        #读取源码路径下的所有.h和.m 文件
        def openSrcFile(path):
            print("开始处理路径： "+ path +"  下的所有.h和.m文件")
            # this folder is custom
            for parent,dirnames,filenames in os.walk(path):
                #case 1:
        #        for dirname in dirnames:
        #            print((" parent folder is:" + parent).encode('utf-8'))
        #            print((" dirname is:" + dirname).encode('utf-8'))
                #case 2
                for filename in filenames:
                    extendedName = os.path.splitext(os.path.join(parent,filename))
                    if (extendedName[1] == '.h' or extendedName[1] == '.m'):
                        print("处理源代码文件: "+ os.path.join(parent,filename))
                        obfuscate(os.path.join(parent,filename))


        #源码路径
        srcPath = '../\(dirPath)'

        if __name__ == '__main__':
            print("本脚本用于对源代码中被标记的字符串进行加密")

            if len(srcPath) > 0:
                openSrcFile(srcPath)
            else:
                print("请输入正确的源代码路径")
                sys.exit()
        """
    }
    public static func decodeConfusion(_ dirPath:String="")->String{
        return """
        #!/usr/bin/env python
        # encoding=utf8
        # -*- coding: utf-8 -*-
        # 本脚本用于对源代码中的字符串进行解密
        # 替换所有加密的char数组为字符串常量，""

        import importlib
        import os
        import re
        import sys


        # 替换((char[]){1, 2, 3, 0})的形式为字符串，同时让每个数组值与0xAA异或进行解密
        def replace(match):
            string = match.group(2)
            decodeConfusion_string = ""
            for numberStr in list(string.split(',')):
                if int(numberStr) != 0:
                    decodeConfusion_string = decodeConfusion_string + "%c" % (int(numberStr) ^ 0xAA)

            # replaced_string = '\"' + "".join(["%c" % ((int(c) ^ 0xAA) if int(c) != 0 else '\0') for c in string.split(',')]) + '\"'
            replaced_string = '\"' + decodeConfusion_string + '\"'
            print("replaced_string = " + replaced_string)

            return match.group(1) + replaced_string + match.group(3)


        # 修改源代码，加入字符串加密的函数
        def obfuscate(file):
            with open(file, 'r') as f:
                code = f.read()
                f.close()
                code = re.sub(r'(confusion_NSSTRING\\(|confusion_CSTRING\\()\\(\\(char \\[\\]\\) \\{(.*?)\\}\\)(\\))', replace, code)
                code = re.sub(r'[/]*#define ggh_confusion', '//#define ggh_confusion', code)
                with open(file, 'w') as f:
                    f.write(code)
                    f.close()


        #读取源码路径下的所有.h和.m 文件
        def openSrcFile(path):
            print("开始处理路径： "+ path +"  下的所有.h和.m文件")
            # this folder is custom
            for parent,dirnames,filenames in os.walk(path):
                #case 1:
        #        for dirname in dirnames:
        #            print((" parent folder is:" + parent).encode('utf-8'))
        #            print((" dirname is:" + dirname).encode('utf-8'))
                #case 2
                for filename in filenames:
                    extendedName = os.path.splitext(os.path.join(parent,filename))
                    #读取所有.h和.m 的源文件
                    if (extendedName[1] == '.h' or extendedName[1] == '.m'):
                        print("处理代码文件:"+ os.path.join(parent,filename))
                        obfuscate(os.path.join(parent,filename))


        #源码路径
        srcPath = '../\(dirPath)'
        if __name__ == '__main__':
            print("字符串解混淆脚本，将被标记过的char数组转为字符串，并和0xAA异或。还原代码")
            if len(srcPath) > 0:
                openSrcFile(srcPath)
            else:
                print("请输入正确的源代码路径！")
                sys.exit()
        """
    }
    
}
