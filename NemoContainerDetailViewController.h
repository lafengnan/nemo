//
//  NemoContainerDetailViewController.h
//  Nemo
//
//  Created by lafengnan on 14-1-6.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NemoContainer;
@interface NemoContainerDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

#pragma mark - Properties

@property (weak, nonatomic) IBOutlet UILabel *bytesUsed;

@property (weak, nonatomic) IBOutlet UILabel *objectCount;
@property (weak, nonatomic) IBOutlet UILabel *createTimeStamp;
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;
@property (weak, nonatomic) IBOutlet UITableView *objectTableView;

@property (retain, nonatomic) NemoContainer *container;

#pragma mark - Instance methods

/** Genereate QR Code Image for specified container
 *  @param container which will be used to generate QR Code
 */

- (UIImage *)generateQRImageWithContainer:(NemoContainer *)container;

#pragma mark - Deprecated methods

- (UIImage *)generateQRImageWithContainer:(NSString *)containerName
                                bytesUsed:(NSString *)bytes
                              objectCount:(NSString *)cnt
                                createdAt:(NSString *)timestamp;

@end
