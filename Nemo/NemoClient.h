//
//  NemoClient.h
//  Nemo
//
//  Created by lafengnan on 13-12-22.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NemoClient : AFHTTPSessionManager

@property (nonatomic, retain)NSString *userName;          // User name of Nemo
@property (nonatomic, retain)NSString *passWord;          // Password of the user

-(id)initUser:(NSString *)user withPassword:(NSString *)passwd;

- (NSDictionary *)setHttpHeader:(NSDictionary *)headerDict;
- (BOOL)authentication:(NSString *)authType;
- (BOOL)swiftPutPath:(NSString *)path container:(NSString *)con object:(NSString *)obj;
- (BOOL)swiftPostPath:(NSString *)path container:(NSString *)con object:(NSString *)obj;
- (BOOL)swiftGetContainer:(NSString *)con object:(NSString *)obj;
- (BOOL)swiftHeadContainer:(NSString *)con object:(NSString *)obj;
- (BOOL)swiftDeleteContainer:(NSString *)con object:(NSString *)obj;

@end
