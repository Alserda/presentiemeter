//
//  PMBackend.m
//  presentiemeter
//
//  Created by Peter Alserda on 17/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import "PMBackend.h"
#import "PMUserLogin.h"
#import <AFNetworking/AFNetworking.h>

/** Base URL */
NSString * const kPresentiemeterBaseURL = @"http://presentiemeter.peperzaken.nl:8123/api/";

/** Path to recieve the employee's location */
NSString * const kPresentiemeterEmployeeLocationPath = @"employees/";

/** Path to updating locations */
NSString * const kPresentiemeterUpdateLocationPath = @"employees/1/update_beacon_location/";

/** Path to update unavailability */
NSString * const kPresentiemeterUpdateUnavailablePath = @"employees/1/out_of_range/";


@implementation PMBackend

/* For being able to access the back-end */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PMBackend *sharedBackend;
    
    dispatch_once(&onceToken, ^{
        sharedBackend = [[PMBackend alloc] init];
    });
    
    return sharedBackend;
}

/* Override the init method to create the operation manager with the base url */
- (instancetype)init {
    self = [super init];
    if (self) {
        self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kPresentiemeterBaseURL]];
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

#pragma mark - Public methods

/* POST request to update a users location to the back-end */
- (void)updateUserLocation:(NSString *)path withLocation:(NSString *)location forUsername:(NSString *)username andEmail:(NSString *)email success:(void(^)(id json))success failure:(void(^)(NSError *error))failure
{
    NSDictionary *params = @{@"full_name": username,
                             @"email": email,
                             @"macaddress": location};
    
    AFHTTPRequestOperation *operation = [self.manager POST:path
                                                parameters:params
                                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                       if (success) {
                                                           // Convert the response object to JSON object (NSArray or NSDictionary)
                                                           success(responseObject);
                                                           NSLog(@"Success: %@", responseObject);
                                                       }
                                                   }
                                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                       if (failure) {
                                                           failure(error);
                                                           NSLog(@"Failed: %@", error);
                                                       }
                                                   }];
}

/* POST request to update the unavailability of a user to the back-end */
- (void)updateUnavailableLocation:(NSString *)path withEmail:(NSString *)email forUsername:(NSString *)username success:(void (^)(id json))success failure:(void (^)(NSError *))failure
{
    NSDictionary *params = @{@"full_name": username,
                             @"email": email};
    
    AFHTTPRequestOperation *operation = [self.manager POST:path
                                         parameters:params
                                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                       if (success) {
                                                           success(responseObject);
                                                           NSLog(@"Unavailable success: %@", responseObject);
                                                       }
                                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                       if (failure) {
                                                           failure(error);
                                                           NSLog(@"Unavailable failed: %@", error);
                                                       }
                                                   }];
}

/* GET request to retrieve the location of all users */
- (void)retrievePath:(NSString *)path success:(void(^)(id json))success failure:(void(^)(NSError *error))failure
{
    AFHTTPRequestOperation *operation = [self.manager GET:path
                                               parameters:nil
                                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                      if (success) {
                                                          // Convert the response object to JSON object (NSArray or NSDictionary)
                                                          success(responseObject);
                                                      }
                                                  }
                                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                      if (failure) {
                                                          failure(error);
                                                      }
                                                  }];
}

@end
