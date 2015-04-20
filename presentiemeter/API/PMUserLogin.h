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

+ (NSDictionary *)authenticatedUserInfo;
+ (BOOL)isAuthenticated;

+ (void)fetchGooglePlusUserData:(void(^)(NSDictionary *googleUserInfo))completed;

@end
