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
