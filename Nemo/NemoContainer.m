//
//  NemoContainer.m
//  Nemo
//
//  Created by lafengnan on 14-1-7.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoContainer.h"

@implementation NemoContainer

@synthesize containerName, metaData;

- (id)init
{
    return [self initWithContainerName:nil withMetaData:nil];
}

- (id)initWithContainerName:(NSString *)name withMetaData:(NSDictionary *)meta
{
    if (self = [super init]) {
        [self setContainerName:name];
        [self setMetaData:meta];
    }
    
    return self;
}

@end
