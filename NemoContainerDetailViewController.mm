//
//  NemoContainerDetailViewController.m
//  Nemo
//
//  Created by lafengnan on 14-1-6.
//  Copyright (c) 2014年 panzhongbin@gmail.com. All rights reserved.
//

#import "NemoContainerDetailViewController.h"
#import "NemoContainer.h"
#import "NemoObject.h"
#import "NemoClient.h"
#import "QREncoder.h"

#define KB (2ll << 10)
#define MB (2ll << 20)
#define GB (2ll << 30)
#define TB (2ll << 40)

@interface NemoContainerDetailViewController ()

@end

@implementation NemoContainerDetailViewController
@synthesize bytesUsed, createTimeStamp, objectCount, qrcodeImageView, objectTableView, container;

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
    
    NMLog(@"%@view will appear", self);
    
    NemoClient *client = [NemoClient getClient];
    
    [client nemoHeadContainer:self.container success:^(NemoContainer *con, NSError *jsonError) {
        
        // Add QR Code Image here
        UIImage *qrcodeImage = [self generateQRImageWithContainer:con];
        
        // CGRect qrcodeImageViewFrame = CGRectMake(35, 250, 100.0, 100.0);
        CGRect qrcodeImageViewFrame = CGRectMake(35, 360, 100.0, 100.0);
        [qrcodeImageView setFrame:qrcodeImageViewFrame];
        
        [self.qrcodeImageView setImage:qrcodeImage];
        
        [[self navigationItem] setTitle:self.container.containerName];
        
        // Lazy init object list here
        self.container.objectList = [[NSMutableArray alloc] init];
        [client nemoGetContainer:self.container success:^(NemoContainer *container, NSError *jsonError) {
            [self.objectTableView reloadData];
        } failure:^(NSURLSessionTask *task, NSError *error) {
            ;
        }];
        [self.view setNeedsDisplay];
    } failure:^(NSURLSessionTask *task, NSError *error) {
        ;
    }];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.objectTableView setDelegate:self];
    [self.objectTableView setDataSource:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance Methods

/** Generate a QRCode Image by using container
 *  @param container the container to generate QR code
 */

- (UIImage *)generateQRImageWithContainer:(NemoContainer *)con
{
    
    // The qrcode is square, now we make it 250 pixels wide
    int qrcodeImageDimension = 120;
    
    /** Set date format and displays it **/
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[con.metaData[@"X-Timestamp"] doubleValue]];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    [self.createTimeStamp setText:formattedDateString];
    
    [self.objectCount setText:con.metaData[@"X-Container-Object-Count"]];
    
    
    NSString *bytesUsedUnit = @" Bytes";
    NSInteger bytes = [con.metaData[@"X-Container-Bytes-Used"] integerValue];
    
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
    
    NSString *imageString = [NSString stringWithFormat:@"Container Name: %@\nUsed Space: %@\nObject Count: %@\nTimestamp: %@", con.containerName, [self.bytesUsed text], [self.objectCount text], [self.createTimeStamp text]];
    NMLog(@"image string:%@", imageString);
    DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:imageString];
    
    // Render the matrix
    UIImage *qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrcodeImageDimension];
    
    return qrcodeImage;
}

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

#pragma mark - tableviwe methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Objects Count: %lu", (unsigned long)[self.container.objectList count]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [self.container.metaData[@"X-Container-Object-Count"] intValue];
    return [self.container.objectList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NemoObject *object = [self.container.objectList objectAtIndex:[indexPath row]];
    NMLog(@"Debug: object size: %@", object.size);
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ObjectList"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ObjectList"];
        [cell.imageView setImage:[UIImage imageNamed:@"file_32.png"]];
        if ([[NSString stringWithFormat:@"%@", object.size] isEqualToString:@"0"]) {
            [cell.imageView setImage:[UIImage imageNamed:@"folder.png"]];
        }
    }
   
    [[cell textLabel] setText:[object objectName]];
//    [[cell textLabel] setTextColor:[UIColor colorWithRed:50.0f/256.0f green:100.0f/256.0f blue:1.0f alpha:1.0f]];
    
    /** Self define new accessory type **/
    
//    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    UIButton *button ;
    if (!tableView.isEditing) {
        UIImage *image= [UIImage imageNamed:@"download_file.png"];
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
        button.frame = frame;
        
        [button setBackgroundImage:image forState:UIControlStateNormal];
        button.backgroundColor= [UIColor clearColor];
        cell.accessoryView= button;
    }
    
    return cell;
}

/** If one row is selected the detail view pops from right
 *  Using a navigationcontroller to controll NemoContainerDetailViewController
 *  and the root controller
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NemoContainerDetailViewController *containerDetailVc = [[NemoContainerDetailViewController alloc] init];
//    
//    NemoContainer *container = [containerList objectAtIndex:[indexPath row]];
//    
//    [containerDetailVc setContainer:container];
//    
//    [self.navigationController pushViewController:containerDetailVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/** Delete the container while left moving tableviewcell
 *  Container could not be delete unless there is no object
 *  in the container
 */

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /* Get client and container which willbe edit */
    __block NemoClient *client = [NemoClient getClient];
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.container.objectList removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation: UITableViewRowAnimationFade];
        
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        //
        //        NemoContainer *newContainer = [[NemoContainer alloc] initWithContainerName:@"new" withMetaData:nil];
        //        [containerList addObject:newContainer];
        [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

@end
