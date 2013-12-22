//
//  NemoAccount.m
//  Nemo
//
//  Created by lafengnan on 13-12-19.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoAccount.h"

@implementation NemoAccount

@synthesize userName, passWord, proxyUrl;

- (id)init
{
    return [self initWithUserName:@"test:tester" andPassword:@"testing" ofUrl:nil];
}
- (id)initWithUserName:(NSString *)name andPassword:(NSString *)key ofUrl:(NSURL *)url
{
    if (self = [super init]) {
        userName = name;
        passWord = key;
        proxyUrl = url;
    }
    return self;
}
@end
