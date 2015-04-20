//
//  PMBackend.h
//  presentiemeter
//
//  Created by Peter Alserda on 17/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import <Foundation/Foundation.h>

// Base URL
extern NSString * const kPresentiemeterBaseURL;

// API paths
extern NSString * const kPresentiemeterUpdateLocationPath;
extern NSString * const kPresentiemeterEmployeeLocationPath;

@class AFHTTPRequestOperationManager;

@interface PMBackend : NSObject

/** Private operation manager to control the communication to our backend */
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

/** Get the global backend communication instance */
+ (instancetype)sharedInstance;

/** POST an updated location to the backend for the specific user/mail combination
 @param location MAC Address of the beacon defining the location
 @param username Full user name
 @param email User identifier email
 */
- (void)updateUserLocation:(NSString *)location forUsername:(NSString *)username andEmail:(NSString *)email;

- (void)retrievePath:(NSString *)path success:(void(^)(id json))success failure:(void(^)(NSError *error))failure;

@end
