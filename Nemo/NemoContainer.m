//
//  NemoContainer.m
//  Nemo
//
//  Created by lafengnan on 14-1-7.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoContainer.h"

@implementation NemoContainer

@synthesize containerName, createTimeStamp, metaData;

- (id)init
{
    return [self initWithContainerName:nil createAt:nil metaData:nil];
}

- (id)initWithContainerName:(NSString *)name createAt:(NSDate *)timeStamp metaData:(NSArray *)meta
{
    if (self = [super init]) {
        [self setContainerName:name];
        [self setCreateTimeStamp:timeStamp];
        [self setMetaData:meta];
    }
    
    return self;
}

@end
