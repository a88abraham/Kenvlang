//
//  JSONUtil.h
//  SessionTest
//
//  Created by hzllb on 14-7-18.
//  Copyright (c) 2014年 hzllb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONUtil : NSObject

-(NSDictionary*)convertJsonToDictionary:(NSString*)jsonStr;

-(NSString*)convertDictionaryToJson:(NSDictionary*)dic;

+ (NSDictionary*)transformJsonToDictionary:(NSString*)jsonStr;

+ (NSString*)transformDictionaryToJson:(NSDictionary*)dic;
@end
