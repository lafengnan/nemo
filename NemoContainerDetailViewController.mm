//
//  NemoContainerDetailViewController.m
//  Nemo
//
//  Created by lafengnan on 14-1-6.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoContainerDetailViewController.h"
#import "NemoContainer.h"
#import "NemoClient.h"
#import "QREncoder.h"

#define KB (2ll << 10)
#define MB (2ll << 20)
#define GB (2ll << 30)
#define TB (2ll << 40)

@interface NemoContainerDetailViewController ()

@end

@implementation NemoContainerDetailViewController
@synthesize bytesUsed, createTimeStamp, objectCount, qrcodeImageView, container;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NMLog(@"view will appear");
    
    NemoClient *client = [NemoClient getClient];
    
    [client nemoHeadContainer:[self.container containerName] success:^(NSString *containerName, NSError *jsonError) {
        
        /** Set date format and displays it **/
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[container.metaData[@"X-Timestamp"] doubleValue]];
        NSString *formattedDateString = [dateFormatter stringFromDate:date];
        [self.createTimeStamp setText:formattedDateString];
        
        [self.objectCount setText:container.metaData[@"X-Container-Object-Count"]];
        
        
        NSString *bytesUsedUnit = @" Bytes";
        NSInteger bytes = [self.container.metaData[@"X-Container-Bytes-Used"] integerValue];
        
        if ( bytes > KB && bytes < MB) {
            
            bytesUsedUnit = @" KB";
            bytes /= KB;
        }
        else if ( bytes > MB &&
                 bytes < GB)
        {
            bytesUsedUnit = @" MB";
            bytes /= MB;
        }
        else if ( bytes > GB && bytes < TB)
        {
            bytesUsedUnit = @" GB";
            bytes /= GB;
        }
        else if (bytes > TB)
        {
            bytes /= TB;
            bytesUsedUnit = @" TB";
        }
        
        [self.bytesUsed setText:[NSString stringWithFormat:@"%ld %@", bytes, bytesUsedUnit]];

        [[self navigationItem] setTitle:self.container.containerName];
        
        // Add QR Code Image here
        
        UIImage *qrcodeImage = [self generateQRImageWithContainer:self.container.containerName
                                                        bytesUsed:[self.bytesUsed text]
                                                      objectCount:[self.objectCount text]
                                                        createdAt:[self.createTimeStamp text]];
        
        CGRect qrcodeImageViewFrame = CGRectMake(35, 266, 125.0, 125.0);
        
        [qrcodeImageView setFrame:qrcodeImageViewFrame];
        
        [self.qrcodeImageView setImage:qrcodeImage];
        
        
        [self.view setNeedsDisplay];
    } failure:^(NSURLSessionTask *task, NSError *error) {
        ;
    }];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance Methods

/** Generate a QRCode Image by using containerName + bytesUsed + ObjectCount string
 *  @param containerName the name of container
 *  @param bytes the bytes-used value converted to NSString 
 *  @param cnt the object-count value converted to NSString
 */

- (UIImage *)generateQRImageWithContainer:(NSString *)containerName bytesUsed:(NSString *)bytes objectCount:(NSString *)cnt createdAt:(NSString *)timestamp
{
    
    // The qrcode is square, now we make it 250 pixels wide
    int qrcodeImageDimension = 125;
    
    NSString *imageString = [NSString stringWithFormat:@"Container Name: %@\nUsed Space: %@\nObject Count: %@\nTimestamp: %@", containerName, bytes, cnt, timestamp];
    NMLog(@"image string:%@", imageString);
    DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:imageString];
    
    // Render the matrix
    UIImage *qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeImageDimension];
    
    return qrcodeImage;
}

@end
