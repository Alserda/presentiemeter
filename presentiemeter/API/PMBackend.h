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
extern NSString * const kPresentiemeterUpdateUnavailablePath;

@class AFHTTPRequestOperationManager;

@interface PMBackend : NSObject

/** Private operation manager to control the communication to our backend */
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

/** Get the global backend communication instance */
+ (instancetype)sharedInstance;

/** POST an updated location to the backend for the specific user/mail combination
 @param path     || The path added to the base URL to post to
 @param location || The identifier of the closest beacon.
 @param username || The users full name.
 @param email    || The users e-mail address.
 @param success  || Block called when the HTTP POST was successfully completed
 @param failure  || Block called when the HTTP POST failed
 */
- (void)updateUserLocation:(NSString *)path
              withLocation:(NSString *)location
               forUsername:(NSString *)username
                  andEmail:(NSString *)email
                   success:(void(^)(id json))success
                   failure:(void(^)(NSError *error))failure;

/** POST the users unavailability to the back-end.
 @param path     || The path added to the base URL to post to
 @param username || The users full name.
 @param email    || The users e-mail address.
 @param success  || Block called when the HTTP POST was successfully completed
 @param failure  || Block called when the HTTP POST failed
 */
- (void)updateUnavailableLocation:(NSString *)path
                        withEmail:(NSString *)email
                      forUsername:(NSString *)username
                          success:(void(^)(id json))success
                          failure:(void(^)(NSError *error))failure;

/** GET request to recieve data 
 @param path     || The path added to the base URL to post to
 @param success  || Block called when the HTTP GET was successfully completed
 @param failure  || Block called when the HTTP GET failed
 */
- (void)retrievePath:(NSString *)path
             success:(void(^)(id json))success
             failure:(void(^)(NSError *error))failure;

@end
