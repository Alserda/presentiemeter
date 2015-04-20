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

@interface PMBackend : NSObject
/** Clear the stored login credentials */
+ (void)fetchGooglePlusUserData;

@end
