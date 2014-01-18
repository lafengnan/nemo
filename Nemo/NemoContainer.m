//
//  NemoContainer.m
//  Nemo
//
//  Created by lafengnan on 14-1-7.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoContainer.h"

@implementation NemoContainer

@synthesize containerName, metaData, objectList;

- (id)init
{
    return [self initWithContainerName:nil withMetaData:nil];
}

- (id)initWithContainerName:(NSString *)name withMetaData:(NSMutableDictionary *)meta
{
    if (self = [super init]) {
        [self setContainerName:name];
        [self setMetaData:meta];
        // Lazy Initialization of objectList
        // Object List is not initialized unitl Object count > 0
        [self setObjectList:nil];
    }
    
    return self;
}

#pragma mark - Instance Methods

- (BOOL)isEqualToContainer:(NemoContainer *)destContainer
{
    BOOL rc = NO;
    if (destContainer) {
        if ([self.containerName isEqualToString:destContainer.containerName]) {
            rc = YES;
        }
    }
    return rc;
}

/** Make NemoContainer instance copyable by using deep copying
 *  @param zone
 */

- (id)copyWithZone:(NSZone *)zone
{
    NemoContainer *container = [[self class] allocWithZone:zone];
    
    [container setContainerName:[containerName copy]];
    [container setMetaData:[metaData copy]];
    [container setObjectList:[objectList copy]];
    
    return container;
}

@end
