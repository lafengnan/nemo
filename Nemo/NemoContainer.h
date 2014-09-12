//
//  NemoContainer.h
//  Nemo
//
//  Created by lafengnan on 14-1-7.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NemoObject;


#pragma mark Enum

typedef NS_ENUM(NSInteger, NemoContainerMetaDataType) {
    NemoContainerMetaDataTypeRetention,
    NemoContainerMetadataTypeTest,
    NemoContainerMetaDataTypeProduct
};

@interface NemoContainer : NSObject <NSCopying>

#pragma mark - Properties

@property (nonatomic, retain) NSString *containerName;
@property (nonatomic, retain) NSMutableDictionary *metaData;
@property (nonatomic, retain) NSMutableArray *objectList;


#pragma mark - Initializer

- (id)initWithContainerName:(NSString *)name withMetaData:(NSMutableDictionary *)meta;
- (id)init;

#pragma mark - Compare

- (BOOL)isEqualToContainer:(NemoContainer *)destContainer;

@end
