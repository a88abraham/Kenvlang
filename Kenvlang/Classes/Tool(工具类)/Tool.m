//
//  Tool.m
//  UILabel的使用
//
//  Created by h.xie on 14-8-1.
//  Copyright (c) 2014年 huangdl. All rights reserved.
//

#import "Tool.h"

#import <CommonCrypto/CommonDigest.h>
#import "GTMBase64.h"
#import <CommonCrypto/CommonCryptor.h>
//#import "NoticeWithOutDataView.h"

static Byte iv[] = {1,2,3,4,5,6,7,8};

#define MAXADDRS 32
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
extern char *if_names[MAXADDRS];
extern char *ip_names[MAXADDRS];
extern char *hw_addrs[MAXADDRS];
extern unsigned long ip_addrs[MAXADDRS];

// Function prototypes

void InitAddresses();
void FreeAddresses();
void GetIPAddresses();
void GetHWAddresses();

/*
 *  IPAddress.c
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/sockio.h>
#include <net/if.h>
#include <errno.h>
#include <net/if_dl.h>
#include <net/ethernet.h>

#define min(a,b) ((a) < (b) ? (a) : (b))
#define max(a,b) ((a) > (b) ? (a) : (b))
#define BUFFERSIZE 4000

char *if_names[MAXADDRS];
char *ip_names[MAXADDRS];
char *hw_addrs[MAXADDRS];
unsigned long ip_addrs[MAXADDRS];

static int  nextAddr = 0;

void InitAddresses()
{
    int i;
    for (i=0; i<MAXADDRS; ++i)
    {
        if_names[i] = ip_names[i] = hw_addrs[i] = NULL;
        ip_addrs[i] = 0;
    }
}

void FreeAddresses()
{
    int i;
    for (i=0; i<MAXADDRS; ++i)
    {
        if (if_names[i] != 0) free(if_names[i]);
        if (ip_names[i] != 0) free(ip_names[i]);
        if (hw_addrs[i] != 0) free(hw_addrs[i]);
        ip_addrs[i] = 0;
    }
    
    InitAddresses();
}

void GetIPAddresses()
{
    int                i, len, flags;
    char                buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifconf      ifc;
    struct ifreq        *ifr, ifrcopy;
    struct sockaddr_in *sin;
    char temp[80];
    int sockfd;
    for (i=0; i<MAXADDRS; ++i)
    {
        if_names[i] = ip_names[i] = NULL;
        ip_addrs[i] = 0;
    }
    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("socket failed");
        return;
    }
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0)
    {
        perror("ioctl error");
        return;
    }
    lastname[0] = 0;
    for (ptr = buffer; ptr < buffer + ifc.ifc_len; )
    {
        ifr = (struct ifreq *)ptr;
        len = max(sizeof(struct sockaddr), ifr->ifr_addr.sa_len);
        ptr += sizeof(ifr->ifr_name) + len; // for next one in buffer
        if (ifr->ifr_addr.sa_family != AF_INET)
        {
            continue; // ignore if not desired address family
        }
        
        if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL)
        {
            *cptr = 0; // replace colon will null
        }
        
        if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0)
        {
            continue; /* already processed this interface */
        }
        memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
        ifrcopy = *ifr;
        ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
        flags = ifrcopy.ifr_flags;
        if ((flags & IFF_UP) == 0)
        {
            continue; // ignore if interface not up
        }
        if_names[nextAddr] = (char *)malloc(strlen(ifr->ifr_name)+1);
        if (if_names[nextAddr] == NULL)
        {
            return;
        }
        
        strcpy(if_names[nextAddr], ifr->ifr_name);
        sin = (struct sockaddr_in *)&ifr->ifr_addr;
        strcpy(temp, inet_ntoa(sin->sin_addr));
        ip_names[nextAddr] = (char *)malloc(strlen(temp)+1);
        
        if (ip_names[nextAddr] == NULL)
        {
            return;
        }
        strcpy(ip_names[nextAddr], temp);
        ip_addrs[nextAddr] = sin->sin_addr.s_addr;
        ++nextAddr;
    }
    
    close(sockfd);
    
}

void GetHWAddresses()
{
    struct ifconf ifc;
    struct ifreq *ifr;
    int i, sockfd;
    char buffer[BUFFERSIZE], *cp, *cplim;
    char temp[80];
    for (i=0; i<MAXADDRS; ++i)
    {
        hw_addrs[i] = NULL;
    }
    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("socket failed");
        return;
    }
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    if (ioctl(sockfd, SIOCGIFCONF, (char *)&ifc) < 0)
    {
        perror("ioctl error");
        close(sockfd);
        return;
    }
    
    ifr = ifc.ifc_req;
    cplim = buffer + ifc.ifc_len;
    for (cp=buffer; cp < cplim; )
    {
        ifr = (struct ifreq *)cp;
        if (ifr->ifr_addr.sa_family == AF_LINK)
        {
            struct sockaddr_dl *sdl = (struct sockaddr_dl *)&ifr->ifr_addr;
            int a,b,c,d,e,f;
            int i;
            strcpy(temp, (char *)ether_ntoa((struct ether_addr*)LLADDR(sdl)));
            sscanf(temp, "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f);
            sprintf(temp, "%02X:%02X:%02X:%02X:%02X:%02X",a,b,c,d,e,f);
            for (i=0; i<MAXADDRS; ++i)
            {
                if ((if_names[i] != NULL) && (strcmp(ifr->ifr_name, if_names[i]) == 0))
                {
                    if (hw_addrs[i] == NULL)
                    {
                        hw_addrs[i] = (char *)malloc(strlen(temp)+1);
                        strcpy(hw_addrs[i], temp);
                        break;
                    }
                }
            }
        }
        cp += sizeof(ifr->ifr_name) + max(sizeof(ifr->ifr_addr), ifr->ifr_addr.sa_len);
    }
    close(sockfd);
}

@implementation Tool


//做ios版本之间的适配
//不同的ios版本,调用不同的方法,实现相同的功能
+(CGSize)sizeOfStr:(NSString *)str andFont:(UIFont *)font andMaxSize:(CGSize)size andLineBreakMode:(NSLineBreakMode)mode
{
    CGSize s;
    if (IOS7_OR_LATER) {
        NSMutableDictionary  *mdic=[NSMutableDictionary dictionary];
        [mdic setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
        [mdic setObject:font forKey:NSFontAttributeName];
        s = [str boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:mdic context:nil].size;
    }
//    else
//    {
//#warning Before IOS 7.0
//        s=[str sizeWithFont:font constrainedToSize:size lineBreakMode:mode];
//    }
    return s;
}

+(void) showAlert:(NSString*) message{
    [Tool showAlertWithTitle:@"提示" message:message];
}
+(void) showAlertWithTitle:(NSString *)title message:(NSString*) message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}
#pragma mark - 改变图片大小,保持图片的长宽比
+(UIImage*)changeSizeOfImgKeepScale:(UIImage*)sourceImg andMaxLength:(NSInteger)maxWidth andMaxHeight:(NSInteger)maxheight
{
    float width=sourceImg.size.width;
    float height=sourceImg.size.height;
    
    if (width<=maxWidth && height<=maxheight) {
        return sourceImg;
    }
    
    if (width/height<=maxWidth/maxheight) {
        return [Tool changeSizeOfImg:sourceImg andWidth:maxheight/height*width andHeight:maxheight];
    }
    if (width/height>=maxWidth/maxheight) {
        return [Tool changeSizeOfImg:sourceImg andWidth:maxWidth andHeight:maxWidth/width*height];
    }
    return nil;
}

#pragma mark - 改变图片的大小
+(UIImage*)changeSizeOfImg:(UIImage*)sourceImg andWidth:(NSInteger)width andHeight:(NSInteger)height
{
    CGSize size=CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    //获取上下文内容
    CGContextRef ctx= UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    //重绘image
    CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, size.width, size.height), sourceImg.CGImage);
    //根据指定的size大小得到新的image
    UIImage* scaled= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaled;
}
#pragma mark - 访问的url,如果里面有中文或者特殊符号,需要先对字符串进行转码
+(NSString*) urlEncodingToUTF8:(NSString*) sourceUrl{
     NSString* encodedString = (NSString*) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)sourceUrl, NULL, NULL, kCFStringEncodingUTF8));
    return encodedString;
}
#pragma mark - 获取设备IP地址
+ (NSString *)deviceIPAdress {
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    return [NSString stringWithFormat:@"%s", ip_names[1]];
}
#pragma mark - 颜色转换 IOS中十六进制的颜色转换为UIColor
+(UIColor*) UIColorFromRGB:(NSUInteger)rgbValue{
    UIColor* color = [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
    return color;
}
+(UIColor*) colorWithHexString:(NSString*) color{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
    
}


+(UIColor*) colorWithHexString:(NSString*) color alpha:(CGFloat) alphaValue {
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alphaValue];
    
}


#pragma mark - 通过文件名获取bundlePath目录的文件
+(NSString *)getBundlePathWithFileName:(NSString *)fileName
{
    return [[NSBundle mainBundle]pathForResource:fileName ofType:nil];
}


+ (NSString *) stringFromMD5:(NSString *)str
{
    
    if(str == nil || [str length] == 0)
        return nil;
    
    const char *value = [str UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    NSString *outString = [outputString uppercaseString];
    return outString;
}


+ (NSString *) myJsonStr:(NSString *)str
{
    NSMutableString *string = [NSMutableString stringWithString:str];
    
    [string stringByReplacingOccurrencesOfString:@"k" withString:@"K"];
    [string stringByReplacingOccurrencesOfString:@")" withString:@"]"];
    return string;
}



//sPicUrl原始图片url  sPreFix需要插入的前缀
+(NSString*) subImgUrl:(NSString*)sPicUrl andPreFix:(NSString*)sPreFix
{
    
    NSString* sResult=sPicUrl;
    NSRange range =  [sPicUrl rangeOfString:@"/" options:NSBackwardsSearch];
    if(range.length>0 && range.location>0)
    {
        NSMutableString* sTemp=[NSMutableString stringWithString:sPicUrl];
        [sTemp insertString:sPreFix atIndex:range.location+1];
        sResult=sTemp;
    }
    return sResult;
}




+ (NSString*)encodeBase64String:(NSString* )input {
    NSData*data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 encodeData:data];
    NSString*base64String = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] ;
    return base64String;
}

+ (NSString*)decodeBase64String:(NSString* )input {
    NSData*data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 decodeData:data];
    NSString*base64String = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] ;
    return base64String;
}

/**
 字节转化为16进制数
 */
+(NSString *) parseByte2HexString:(Byte *) bytes
{
    NSMutableString *hexStr = [[NSMutableString alloc]init];
    int i = 0;
    if(bytes)
    {
        while (bytes[i] != '\0')
        {
            NSString *hexByte = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
            if([hexByte length]==1)
                [hexStr appendFormat:@"0%@", hexByte];
            else
                [hexStr appendFormat:@"%@", hexByte];
            
            i++;
        }
    }
    return hexStr;
}


/**
 字节数组转化16进制数
 */
+(NSString *) parseByteArray2HexString:(Byte[]) bytes
{
    NSMutableString *hexStr = [[NSMutableString alloc]init];
    int i = 0;
    if(bytes)
    {
        while (bytes[i] != '\0')
        {
            NSString *hexByte = [NSString stringWithFormat:@"%x",bytes[i] & 0xff];///16进制数
            if([hexByte length]==1)
                [hexStr appendFormat:@"0%@", hexByte];
            else
                [hexStr appendFormat:@"%@", hexByte];
            
            i++;
        }
    }
    return [hexStr uppercaseString];
}

/*
 将16进制数据转化成NSData 数组
 */
+(NSData*) parseHexToByteArray:(NSString*) hexString
{
    int j=0;
    Byte bytes[hexString.length];
    for(int i=0;i<[hexString length];i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        
        int_ch = int_ch1+int_ch2;
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:hexString.length/2];

    return newData;
}


/*
 DES加密
 */
+(NSString *) encryptUseDES:(NSString *)clearText key:(NSString *)key
{
    NSString *ciphertext = nil;
    NSData *textData = [clearText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [textData length];
    size_t bufferSize = 1024;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          [textData bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
 
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:(NSUInteger)numBytesEncrypted];
        Byte* bb = (Byte*)[data bytes];
        ciphertext = [Tool parseByteArray2HexString:bb];
    }else{
        free(buffer);

    }
    return ciphertext;
}

/**
 DES解密
 */
+(NSString *) decryptUseDES:(NSString *)plainText key:(NSString *)key
{
    NSString *cleartext = nil;
    NSData *textData = [Tool parseHexToByteArray:plainText];
    NSUInteger dataLength = [textData length];
    size_t bufferSize = 1024;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionECBMode,
                                          [key UTF8String], kCCKeySizeDES,
                                          iv,
                                          [textData bytes]	, dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
 
        
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:(NSUInteger)numBytesEncrypted];
        cleartext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }else{
        free(buffer);
 
    }
    return cleartext;
}

//+ (void) showEmptyDataNoticeViewInViewController:(UIViewController *)viewController
//{
//    NoticeWithOutDataView *view = [[NoticeWithOutDataView alloc] init];
//    view.backgroundColor = [UIColor clearColor];
//    [viewController.view addSubview:view];
//    [view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(viewController.view);
//        make.width.equalTo(@200);
//        make.height.equalTo(@100);
//    }];
//    UIImageView *imgV = [[UIImageView alloc] init];
//    [view addSubview:imgV];
//    imgV.image = IMAGE(@"img_placeholder_banner");
//    [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(view);
//        make.top.equalTo(view);
//        make.height.equalTo(@70);
//        make.width.equalTo(@180);
//    }];
//    UILabel *lb = [[UILabel alloc] init];
//    lb.text = @"暂无数据";
//    lb.font = [UIFont systemFontOfSize:14];
//    lb.textAlignment = NSTextAlignmentCenter;
//    lb.textColor = [Tool colorWithHexString:@"#88d3a9"];
//    [view addSubview:lb];
//    [lb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(imgV.mas_bottom).offset(5);
//        make.leading.equalTo(view);
//        make.trailing.equalTo(view);
//        make.bottom.equalTo(view);
//    }];
//}
//
//+ (void) removeNoticeViewInViewController:(UIViewController *)vc
//{
//    for (UIView *view in vc.view.subviews) {
//                
//        if ([view isKindOfClass:[NoticeWithOutDataView class]]) {
//            [view removeFromSuperview];
//            break;
//
//        }
//    }
//    
//}


@end








