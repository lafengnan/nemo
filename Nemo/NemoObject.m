//
//  NemoObject.m
//  Nemo
//
//  Created by lafengnan on 14-1-12.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoObject.h"
#import "NemoContainer.h"

@implementation NemoObject
@synthesize objectName, fileExtension, metaData, size, etag,lastModified, contentType, masterContainer;


#pragma mark - Initializer

- (id)init
{
    return [self initWithObjectName:@"object" fileExtension:@"file" andMetaData:nil];
}

- (id)initWithObjectName:(NSString *)name fileExtension:(NSString *)extension andMetaData:(NSMutableDictionary *)meta
{
    if (self = [super init]) {
        [self setObjectName:name];
        [self setFileExtension:extension];
        [self setMetaData:meta];
        [self setSize:@"0"];
        [self setEtag:@"b125ddd05b8011a7f6568210d3a3325d"];
        [self setLastModified:@"2014-1-1"];
        [self setContentType:@"application/octet-stream"];
    }
    
    return self;
}

- (BOOL)isEqualToObject:(NemoObject *)destObj
{
    if (self && destObj) {
        if ([self.objectName isEqualToString:destObj.objectName]) {
            if ([self.masterContainer.containerName isEqualToString:destObj.masterContainer.containerName]) {
                return YES;
            }
        }
        else
            return NO;
    }
    return  NO;
}


@end
