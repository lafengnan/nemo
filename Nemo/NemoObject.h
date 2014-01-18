//
//  NemoObject.h
//  Nemo
//
//  Created by lafengnan on 14-1-12.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NemoContainer;

@interface NemoObject : NSObject

#pragma mark - Properties

@property (nonatomic, retain) NSString *objectName;
@property (nonatomic, retain) NSString *size;
@property (nonatomic, retain) NSString *etag;
@property (nonatomic, retain) NSString *lastModified;
@property (nonatomic, retain) NSString *contentType;
@property (nonatomic, retain) NSString *fileExtension;
@property (nonatomic, retain) NSMutableDictionary *metaData;
@property (nonatomic, weak) NemoContainer *masterContainer;


#pragma mark - Initializer

- (id)initWithObjectName:(NSString *)name fileExtension:(NSString *)extension andMetaData:(NSMutableArray *)meta;

#pragma mark - Compare

- (BOOL)isEqualToObject:(NemoObject *)destObj;


@end
