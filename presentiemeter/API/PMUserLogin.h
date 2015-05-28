//
//  PMUserLogin.h
//  presentiemeter
//
//  Created by Peter Alserda on 20/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMUserLogin : NSObject

@property (nonatomic, strong) NSDictionary *googlePlusUserInfo;

/** The user info, stored in the user defaults */
+ (NSDictionary *)authenticatedUserInfo;

/** A boolean to check if the user is already authenticated */
+ (BOOL)isAuthenticated;

/** The request to fetch the users google data */
+ (void)fetchGooglePlusUserData:(void(^)(NSDictionary *googleUserInfo))completed;

@end
