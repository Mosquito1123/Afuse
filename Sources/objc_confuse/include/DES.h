//
//  File.swift
//  
//
//  Created by Mosquito1123 on 06/12/2019.
//

#import <Foundation/Foundation.h>
@interface DES : NSObject

+(NSString *)encryptUseDES2:(NSString *)plainText key:(NSString *)key;
+ (NSString *)decryptUseDES:(NSString *)cipherText key:(NSString *)key;


+(NSString *)encryptUseDES2M:(NSMutableString *)plainText key:(NSString *)key;
+(NSString *)decryptUseDESM:(NSMutableString *)cipherText key:(NSString *)key;
@end
