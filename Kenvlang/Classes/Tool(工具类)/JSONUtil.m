//
//  JSONUtil.m
//  SessionTest
//
//  Created by hzllb on 14-7-18.
//  Copyright (c) 2014年 hzllb. All rights reserved.
//

#import "JSONUtil.h"

@implementation JSONUtil



-(NSDictionary*)convertJsonToDictionary:(NSString*)jsonStr
{
    return [JSONUtil transformJsonToDictionary:jsonStr];
}
-(NSString*)convertDictionaryToJson:(NSDictionary*)dic
{
    return [JSONUtil transformDictionaryToJson:dic];
}

+ (NSString *)transformDictionaryToJson:(NSDictionary *)dic
{
    
    if (dic == nil) {
        return nil;
    }
    NSError *error = nil;

    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
    if(error != nil)
    {
        return nil;
        
    }
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return str;

}

+ (NSDictionary *)transformJsonToDictionary:(NSString *)jsonStr
{
    
    if (jsonStr == nil) {
        return nil;
    }
    
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
    NSRange range = [jsonStr rangeOfCharacterFromSet:controlChars];
    if (range.location != NSNotFound) {
        NSMutableString *mutableString = [NSMutableString stringWithString:jsonStr];
        while (range.location != NSNotFound) {
            [mutableString deleteCharactersInRange:range];
            range = [mutableString rangeOfCharacterFromSet:controlChars];
        }
        jsonStr = mutableString;
    }
    
    NSError *error = nil;
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    if(error != nil)
    {
        return nil;
        
    }
    return result;

}

@end
