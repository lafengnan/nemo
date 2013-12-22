//
//  NemoAccount.h
//  Nemo
//
//  Created by lafengnan on 13-12-19.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NemoAccount : NSObject

@property NSString *userName;
@property NSString *passWord;
@property NSURL *proxyUrl;

- (id)initWithUserName:(NSString *)userName andPassword:(NSString*)passWord ofUrl:(NSURL *)url;

@end
