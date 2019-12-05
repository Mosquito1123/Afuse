#import <Foundation/Foundation.h>
@interface DES3EncryptUtil : NSObject
// 加密方法
+ (NSString*)encrypt:(NSString*)plainText key:(NSString *)key iv:(NSString *)iv;
// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText key:(NSString *)key iv:(NSString *)iv;
@end
