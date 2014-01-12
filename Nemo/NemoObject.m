//
//  NemoObject.m
//  Nemo
//
//  Created by lafengnan on 14-1-12.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoObject.h"

@implementation NemoObject
@synthesize objectName, objectTypeImage, objectMetaData, size, etag,lastUpdated, contentType;


#pragma mark - Initializer

- (id)init
{
    return [self initWithObjectName:@"object" imageType:nil andMetaData:nil];
}

- (id)initWithObjectName:(NSString *)name imageType:(UIImage *)image andMetaData:(NSMutableArray *)meta
{
    if (self = [super init]) {
        [self setObjectName:name];
        [self setObjectTypeImage:image];
        [self setObjectMetaData:meta];
        [self setSize:@"0"];
        [self setEtag:@"b125ddd05b8011a7f6568210d3a3325d"];
        [self setLastUpdated:@"2014-1-1"];
        [self setContentType:@"application/octet-stream"];
    }
    
    return self;
}



@end
