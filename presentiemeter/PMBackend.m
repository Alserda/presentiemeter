//
//  PMBackend.m
//  presentiemeter
//
//  Created by Peter Alserda on 17/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import "PMBackend.h"

#import <EstimoteSDK/EstimoteSDK.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "AFNetworking.h"

// Base URL
NSString * const kPresentiemeterBaseURL = @"http://presentiemeter.peperzaken.nl:8000/api/";

// URL's for updating locations
NSString * const kPresentiemeterUpdateLocationPath = @"employees/1/update_location/";

NSString * const kPresentiemeterEmployeeLocationPath = @"employees/";


@implementation PMBackend

- (void)fetchGooglePlusUserData {
    // 1. Create a |GTLServicePlus| instance to send a request to Google+.
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init] ;
    plusService.retryEnabled = YES;
    
    // 2. Set a valid |GTMOAuth2Authentication| object as the authorizer.
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
    
    
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    
    // *4. Use the "v1" version of the Google+ API.*
    plusService.apiVersion = @"v1";
    
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
                if (error) {
                    
                    
                    
                    //Handle Error
                    
                } else
                {
                    self.googlePlusUserInfo = @{
                                                @"email" : [GPPSignIn sharedInstance].authentication.userEmail,
                                                @"full_name" : [person.name.givenName stringByAppendingFormat:@" %@",person.name.familyName]
                                                };
                    
                    
                    // It's possible to retrieve:
                    // GoogleID with "person.identifier".
                    // Gender with "person.gender".
                    
                    
                    NSLog(@"User information: %@", self.googlePlusUserInfo);
                    
                    
                }
                
            }];
}

@end