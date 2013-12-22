//
//  NemoClient.h
//  Nemo
//
//  Created by lafengnan on 13-12-22.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NemoAccount;

@interface NemoClient : NSObject

@property (nonatomic, retain) NemoAccount *userInfo;

-(id)initWithUserInfo:(NemoAccount *)user;
-(BOOL)isUserInfoValid;

@end
