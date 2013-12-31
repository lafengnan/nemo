//
//  NemoClient.h
//  Nemo
//
//  Created by lafengnan on 13-12-22.
//  Copyright (c) 2013年 panzhongbin@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NemoClient : AFHTTPSessionManager

#pragma mark - Properties

@property (nonatomic, retain) NSString *userName;          // User name of Nemo
@property (nonatomic, retain) NSString *passWord;          // Password of the user
@property (nonatomic, retain) NSURL *authUrl;              // The authentication URL
@property (nonatomic, retain) NSString *authToken;         // Authentication token generated by user and password
@property (nonatomic) BOOL authenticated;                  // Set to YES when client get authenticated
@property (nonatomic, retain) NSString *storageUrl;        // Storage url get from authentication = proxyUrl/v1/account
@property (nonatomic, retain) NSHTTPURLResponse *response; // Response from swift-backend


#pragma mark - Class method

+ (id)client;

#pragma mark - Constructors


/** Create a singleton client for NemoClient **/
+ (void)initialize;

/** Create a Nemo Client with specified user and password
 *  @param url The URL to use for authentication
 *  @param user Your user name
 *  @param passwd Your password associated with the user
 */
- (id)initWithAuthURL:(NSURL *)url User:(NSString *)user withPassword:(NSString *)passwd;

#pragma mark - Authentication

/** Authentication shoud run in sync mode, otherwise the auth token would not be get
 *  while login view changes to table view
 */
- (BOOL)authentication:(NSString *)authType;
- (BOOL)getTempAuth;

#pragma mark - Http Operations

- (void)setHttpHeader:(NSDictionary *)headerDict;

/** Get container list in the account
 *  @param successHandler executes if successful
 *  @param failureHandler exectues if failed
 */
- (void)nemoGetAccount:(void (^)(NSArray *containers, NSError *jsonError))success failure:(void(^)(NSURLSessionDataTask *, NSError *error))failure ;
/*

- (void)nemoPutPath:(NSString *)path container:(NSString *)con object:(NSString *)obj;
- (void)nemoPostPath:(NSString *)path container:(NSString *)con object:(NSString *)obj;

- (void)nemoHeadContainer:(NSString *)con object:(NSString *)obj;
- (void)nemoDeleteContainer:(NSString *)con object:(NSString *)obj;
 
 */

#pragma mark - 

- (void)displayClientInfo;

@end
