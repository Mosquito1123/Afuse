#import <Foundation/Foundation.h>
@interface DES3EncryptUtil : NSObject
// 加密方法
+ (NSString*)encrypt:(NSString*)plainText;
// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText;
@end
