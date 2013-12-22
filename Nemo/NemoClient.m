//
//  NemoClient.m
//  Nemo
//
//  Created by lafengnan on 13-12-22.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoClient.h"
#import "NemoAccount.h"

@implementation NemoClient

@synthesize userInfo;


-(id)init
{
    NemoAccount *user = [[NemoAccount alloc] initWithUserName:@"test:tester"
                                                  andPassword:@"testing"
                         ofUrl:nil];
    return [self initWithUserInfo:user];
}
-(id)initWithUserInfo:(NemoAccount *)user
{
    if (self = [super init]) {
        [self setUserInfo:user];
    }
    return self;
}
-(BOOL)isUserInfoValid
{
    BOOL rc = YES;
    
    
    // Using fake authentication code here, will be replaced by
    // real user/password information fetched from swift-backend
    if ([[userInfo userName] isEqualToString:@"test:tester"] &&
        ![[userInfo passWord] isEqualToString:@"testing"]) {
        
        rc = NO;
        NSLog(@"User Name:%@, Password:%@ are invalid", [userInfo userName], [userInfo passWord]);
    }
    
    return rc;
}

@end
