//
//  NemoClient.h
//  Nemo
//
//  Created by lafengnan on 13-12-22.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NemoClient : NSObject

@property (nonatomic, retain)NSString *userName;          // User name of Nemo
@property (nonatomic, retain)NSString *passWord;          // Password of the user
@property (nonatomic, copy)NSURL *storageUrl;             // Proxy url of swift-backend
@property (nonatomic, retain)NSDictionary *metaData;      // The metadata which will be set



-(id)initUser:(NSString *)user withPassword:(NSString *)passwd forUrl:(NSURL *)url withMeta:(NSDictionary *)meta;
-(NSString *)getToken;


@end
