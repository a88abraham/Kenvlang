//
//  Tool.h
//  UILabel的使用
//
//  Created by huangdl on 14-5-8.
//  Copyright (c) 2014年 huangdl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Tool : NSObject

+(CGSize)sizeOfStr:(NSString *)str andFont:(UIFont *)font andMaxSize:(CGSize)size andLineBreakMode:(NSLineBreakMode)mode;

+(UIImage*)changeSizeOfImgKeepScale:(UIImage*)sourceImg andMaxLength:(NSInteger)maxWidth andMaxHeight:(NSInteger)maxheight;

+(UIImage*)changeSizeOfImg:(UIImage*)sourceImg andWidth:(NSInteger)width andHeight:(NSInteger)height;

+(NSString*) urlEncodingToUTF8:(NSString*) sourceUrl;

+(void) showAlert:(NSString*) message;

+(void) showAlertWithTitle:(NSString *)title message:(NSString*) message;

+(NSString *) deviceIPAdress;

+(UIColor*) UIColorFromRGB:(NSUInteger)rgbValue;

+(UIColor*) colorWithHexString:(NSString*) color;

+(UIColor*) colorWithHexString:(NSString*) color alpha:(CGFloat) alphaValue;

+(NSString *)getBundlePathWithFileName:(NSString *)fileName;

+(NSString *) stringFromMD5:(NSString *)str;

+ (NSString *) myJsonStr:(NSString *)str;

+(NSString*) subImgUrl:(NSString*)sPicUrl andPreFix:(NSString*)sPreFix;


+ (NSString*)encodeBase64String:(NSString*)input;

+ (NSString*)decodeBase64String:(NSString*)input;

/**
 字节转化为16进制数
 */
+(NSString *) parseByte2HexString:(Byte *) bytes;

/**
 字节数组转化16进制数
 */
+(NSString *) parseByteArray2HexString:(Byte[]) bytes;

/*
 将16进制数据转化成NSData 数组
 */
+(NSData*) parseHexToByteArray:(NSString*) hexString;

/**
 DES加密
 */
+(NSString *) encryptUseDES:(NSString *)plainText key:(NSString *)key;

/**
 DES解密
 */

+(NSString *) decryptUseDES:(NSString *)plainText key:(NSString *)key;


/**
 *  显示没有数据时候的提示视图 (只能在本项目中使用)
 *
 *  @param viewController vc
 */
+ (void) showEmptyDataNoticeViewInViewController:(UIViewController *)viewController;


/**
 *  移除无数据提示
 *
 *  @param vc vc
 */
+ (void) removeNoticeViewInViewController:(UIViewController *)vc;

@end









