//
//  File.swift
//  
//
//  Created by Mosquito1123 on 03/12/2019.
//

import Foundation


public struct Template{
    public static let encryption_tools_h = """
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
@interface EncryptionTools : NSObject

/**
 *  AES加密
 *
 *  @param string    要加密的字符串
 *  @param keyString 加密密钥
 *  @param iv        初始化向量(8个字节)
 *
 *  @return 返回加密后的base64编码字符串
 */
+ (NSString *)aesEncryptString:(NSString *)string keyString:(NSString *)keyString iv:(NSData *)iv;

/**
 *  AES解密
 *
 *  @param string    加密并base64编码后的字符串
 *  @param keyString 解密密钥
 *  @param iv        初始化向量(8个字节)
 *
 *  @return 返回解密后的字符串
 */
+ (NSString *)aesDecryptString:(NSString *)string keyString:(NSString *)keyString iv:(NSData *)iv;

/**
 *  DES加密
 *
 *  @param string    要加密的字符串
 *  @param keyString 加密密钥
 *  @param iv        初始化向量(8个字节)
 *
 *  @return 返回加密后的base64编码字符串
 */
+ (NSString *)desEncryptString:(NSString *)string keyString:(NSString *)keyString iv:(NSData *)iv;

/**
 *  DES解密
 *
 *  @param string    加密并base64编码后的字符串
 *  @param keyString 解密密钥
 *  @param iv        初始化向量(8个字节)
 *
 *  @return 返回解密后的字符串
 */
+ (NSString *)desDecryptString:(NSString *)string keyString:(NSString *)keyString iv:(NSData *)iv;

@end

"""
    public static let encryption_tools_m = """
//
//  File.swift
//
//
//  Created by Mosquito1123 on 06/12/2019.
//


#import "EncryptionTools.h"

@implementation EncryptionTools

//AES加密
+ (NSString *)aesEncryptString:(NSString *)string keyString:(NSString *)keyString iv:(NSData *)iv {
   // 设置秘钥
   NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
   uint8_t cKey[kCCKeySizeAES128];
   bzero(cKey, sizeof(cKey));
   [keyData getBytes:cKey length:kCCKeySizeAES128];
   
   // 设置iv
   uint8_t cIv[kCCBlockSizeAES128];
   bzero(cIv, kCCBlockSizeAES128);
   int option = 0;
   if (iv) {
       [iv getBytes:cIv length:kCCBlockSizeAES128];
       option = kCCOptionPKCS7Padding;
   } else {
       option = kCCOptionPKCS7Padding | kCCOptionECBMode;
   }
   
   // 设置输出缓冲区
   NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
   size_t bufferSize = [data length] + kCCBlockSizeAES128;
   void *buffer = malloc(bufferSize);
   
   // 开始加密
   size_t encryptedSize = 0;
   
   /**
    @constant   kCCAlgorithmAES     高级加密标准，128位(默认)
    @constant   kCCAlgorithmDES     数据加密标准
    */
   CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                         kCCAlgorithmAES,
                                         option,
                                         cKey,
                                         kCCKeySizeAES128,
                                         cIv,
                                         [data bytes],
                                         [data length],
                                         buffer,
                                         bufferSize,
                                         &encryptedSize);
   
   NSData *result = nil;
   if (cryptStatus == kCCSuccess) {
       result = [NSData dataWithBytesNoCopy:buffer length:encryptedSize];
   } else {
       free(buffer);
       NSLog(@"[错误] 加密失败|状态编码: %d", cryptStatus);
   }
   
   return [result base64EncodedStringWithOptions:0];
}

//AES解密
+ (NSString *)aesDecryptString:(NSString *)string keyString:(NSString *)keyString iv:(NSData *)iv {
   // 设置秘钥
   NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
   uint8_t cKey[kCCKeySizeAES128];
   bzero(cKey, sizeof(cKey));
   [keyData getBytes:cKey length:kCCKeySizeAES128];
   
   // 设置iv
   uint8_t cIv[kCCBlockSizeAES128];
   bzero(cIv, kCCBlockSizeAES128);
   int option = 0;
   if (iv) {
       [iv getBytes:cIv length:kCCBlockSizeAES128];
       option = kCCOptionPKCS7Padding;
   } else {
       option = kCCOptionPKCS7Padding | kCCOptionECBMode;
   }
   
   // 设置输出缓冲区，options参数很多地方是直接写0，但是在实际过程中可能出现回车的字符串导致解不出来
   NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
   
   size_t bufferSize = [data length] + kCCBlockSizeAES128;
   void *buffer = malloc(bufferSize);
   
   // 开始解密
   size_t decryptedSize = 0;
   CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                         kCCAlgorithmAES128,
                                         option,
                                         cKey,
                                         kCCKeySizeAES128,
                                         cIv,
                                         [data bytes],
                                         [data length],
                                         buffer,
                                         bufferSize,
                                         &decryptedSize);
   
   NSData *result = nil;
   if (cryptStatus == kCCSuccess) {
       result = [NSData dataWithBytesNoCopy:buffer length:decryptedSize];
   } else {
       free(buffer);
       NSLog(@"[错误] 解密失败|状态编码: %d", cryptStatus);
   }
   
   return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

//DES加密
+ (NSString *)desEncryptString:(NSString *)string keyString:(NSString *)keyString iv:(NSData *)iv {
   // 设置秘钥
   NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
   uint8_t cKey[kCCKeySizeDES];
   bzero(cKey, sizeof(cKey));
   [keyData getBytes:cKey length:kCCKeySizeDES];
   
   // 设置iv
   uint8_t cIv[kCCBlockSizeDES];
   bzero(cIv, kCCBlockSizeDES);
   int option = 0;
   if (iv) {
       [iv getBytes:cIv length:kCCBlockSizeDES];
       option = kCCOptionPKCS7Padding;
   } else {
       option = kCCOptionPKCS7Padding | kCCOptionECBMode;
   }
   
   // 设置输出缓冲区
   NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
   size_t bufferSize = [data length] + kCCBlockSizeDES;
   void *buffer = malloc(bufferSize);
   
   // 开始加密
   size_t encryptedSize = 0;
   
   CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                         kCCAlgorithmDES,
                                         option,
                                         cKey,
                                         kCCKeySizeDES,
                                         cIv,
                                         [data bytes],
                                         [data length],
                                         buffer,
                                         bufferSize,
                                         &encryptedSize);
   
   NSData *result = nil;
   if (cryptStatus == kCCSuccess) {
       result = [NSData dataWithBytesNoCopy:buffer length:encryptedSize];
   } else {
       free(buffer);
       NSLog(@"[错误] 加密失败|状态编码: %d", cryptStatus);
   }
   
   return [result base64EncodedStringWithOptions:0];
}

//DES解密
+ (NSString *)desDecryptString:(NSString *)string keyString:(NSString *)keyString iv:(NSData *)iv {
   // 设置秘钥
   NSData *keyData = [keyString dataUsingEncoding:NSUTF8StringEncoding];
   uint8_t cKey[kCCKeySizeDES];
   bzero(cKey, sizeof(cKey));
   [keyData getBytes:cKey length:kCCKeySizeDES];
   
   // 设置iv
   uint8_t cIv[kCCBlockSizeDES];
   bzero(cIv, kCCBlockSizeDES);
   int option = 0;
   if (iv) {
       [iv getBytes:cIv length:kCCBlockSizeDES];
       option = kCCOptionPKCS7Padding;
   } else {
       option = kCCOptionPKCS7Padding | kCCOptionECBMode;
   }
   
   // 设置输出缓冲区，options参数很多地方是直接写0，但是在实际过程中可能出现回车的字符串导致解不出来
   NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];

   size_t bufferSize = [data length] + kCCBlockSizeDES;
   void *buffer = malloc(bufferSize);
   
   // 开始解密
   size_t decryptedSize = 0;
   CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                         kCCAlgorithmDES,
                                         option,
                                         cKey,
                                         kCCKeySizeDES,
                                         cIv,
                                         [data bytes],
                                         [data length],
                                         buffer,
                                         bufferSize,
                                         &decryptedSize);
   
   NSData *result = nil;
   if (cryptStatus == kCCSuccess) {
       result = [NSData dataWithBytesNoCopy:buffer length:decryptedSize];
   } else {
       free(buffer);
       NSLog(@"[错误] 解密失败|状态编码: %d", cryptStatus);
   }
   
   return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

@end
"""
    public static let shell_script = """
//#!/usr/bin/env bash
pod install
"""
    public static let des_origin_import = """
#import <Foundation/Foundation.h>
"""
    public static let des_confuse_define = """
#import "EncryptionTools.h"
#define aes_decrypt(text,gkey)  [EncryptionTools aesDecryptString:text keyString:gkey iv:nil]
#define aes_encrypt(text,gkey)  [EncryptionTools aesEncryptString:text keyString:gkey iv:nil]
"""
    public static let des_header_import = """
#import "EncryptionTools.h"
"""
    public static let des_decrypt_define = """
#define aes_decrypt(text,gkey) [EncryptionTools aesDecryptString:text keyString:gkey iv:nil]
"""
    public static let des_encrypt_define = """
#define aes_encrypt(text,key)  [EncryptionTools aesEncryptString:text keyString:gkey iv:nil]
"""

    
    public static let new_des_h = """
#import <Foundation/Foundation.h>
@interface DES : NSObject
+(NSString *)encryptUseDES2:(NSString *)plainText key:(NSString *)key;
+(NSString *)decryptUseDES:(NSString *)cipherText key:(NSString *)key;
@end
"""
    public static let new_des_m = """
#import "DES.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation DES : NSObject
//加密
+(NSString *) encryptUseDES2:(NSString *)plainText key:(NSString *)key{
    NSString *ciphertext = nil;
    const char *textBytes = [plainText UTF8String];
    NSUInteger dataLength = [plainText length];
    
    size_t bufferPtrSize = (dataLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    unsigned char* buffer = (unsigned char *)malloc(bufferPtrSize);;
    memset(buffer, 0, bufferPtrSize);
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String], kCCKeySizeDES,
                                          NULL,
                                          textBytes, dataLength,
                                          buffer, bufferPtrSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        
        ciphertext = [[NSString alloc] initWithData:[data base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return ciphertext;
}

+ (NSString *)decryptUseDES:(NSString *)cipherText key:(NSString *)key
{
    NSData* cipherData = [[NSData alloc] initWithBase64EncodedString:cipherText options:0];
    
    NSUInteger dataLength = [cipherText length];
    size_t bufferPtrSize = (dataLength + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    unsigned char* buffer = (unsigned char *)malloc(bufferPtrSize);;
    memset(buffer, 0, bufferPtrSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          NULL,
                                          [cipherData bytes],
                                          [cipherData length],
                                          buffer,
                                          bufferPtrSize,
                                          &numBytesDecrypted);
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData* data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plainText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    free(buffer);
    return plainText;
    
}

@end

"""
    public static func des_h()->String{
        return """
        #import <Foundation/Foundation.h>
        @interface DES3EncryptUtil : NSObject
        // 加密方法
        + (NSString *)encrypt:(NSString *)plainText;
        // 解密方法
        + (NSString *)decrypt:(NSString *)encryptText;
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
        #define gkey @"\(salt)"
        //向量
        #define gIv  @"\(iv)"

        @implementation DES3EncryptUtil : NSObject

        // 加密方法
        + (NSString *)encrypt:(NSString *)plainText {
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
        + (NSString *)decrypt:(NSString *)encryptText {
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
            
            NSString *result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding] ;
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
//        data = [self DESEncrypt:data WithKey:key];
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
//        data = [self DESDecrypt:data WithKey:key];
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
        [NSException raise:NSInvalidArgumentException format:@""];
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
            if (characters[i] == '\\0')
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
            "type":0,
            "confuseStrings": ["/game/config/version.json"],
            "confuseRegexs": ["https://","wss://","http://","ws://"],
            "ignoreStrings":["https://www.stable.com","https://www.hall.com"]
        },
        {
            "className": "NSURLSession+EgretDataTask",
            "type":0,
            "confuseStrings": ["/game/config/version.json"],
            "confuseRegexs": ["https://","wss://","http://","ws://"]
        },
        {
            "className": "ServersManager",
            "type":0,
            "confuseStrings": ["report_push_token","umeng","jpush","type","token"],
            "confuseRegexs": ["https://","wss://","http://","ws://"]
        },
        {
            "className": "EgretViewController",
            "type":0,
            "confuseStrings": ["get_app_info","initialized","openinstall_data","set_key","statistic_user_action","download","quit","reload","open_web","close_web","copy_to_clipboard","composite_bitmap","share","save_bitmap_to_gallery","qq_temporary_session","open_site","open_app","ios_app_exists","auth","get_error_version","set_start_path","network_status","offline","delete_auth"],
            "confuseRegexs": ["https://","wss://","http://","ws://"]
        },
        {
            "className": "Limbs",
            "type":0,
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

            # replaced_string = '\"' + "".join(["%c" % ((int(c) ^ 0xAA) if int(c) != 0 else '\\0') for c in string.split(',')]) + '\"'
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
