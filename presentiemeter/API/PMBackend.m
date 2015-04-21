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

// Base URL
NSString * const kPresentiemeterBaseURL = @"http://presentiemeter.peperzaken.nl:8000/api/";

// URL's for updating locations
NSString * const kPresentiemeterUpdateLocationPath = @"employees/1/update_location/";

NSString * const kPresentiemeterEmployeeLocationPath = @"employees/";


@implementation PMBackend

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PMBackend *sharedBackend;
    dispatch_once(&onceToken, ^{
        sharedBackend = [[PMBackend alloc] init];
    });
    return sharedBackend;
}

// Override the init method to create the operation manager with the base url
- (instancetype)init {
    self = [super init];
    if (self) {
        self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kPresentiemeterBaseURL]];
        self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

#pragma mark - Public methods

- (void)updateUserLocation:(NSString *)path withLocation:(NSString *)location forUsername:(NSString *)username andEmail:(NSString *)email success:(void(^)(id json))success failure:(void(^)(NSError *error))failure {
    
    AFHTTPRequestOperation *operation = [self.manager POST:path
                                                       parameters:nil
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


- (void)retrievePath:(NSString *)path success:(void(^)(id json))success failure:(void(^)(NSError *error))failure {
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
