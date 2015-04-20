//
//  PMUserLogin.m
//  presentiemeter
//
//  Created by Peter Alserda on 20/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import "PMUserLogin.h"

#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

/** This class is used to validate a GooglePlus account
 It's used to store the user data */
@implementation PMUserLogin

+ (NSDictionary *)authenticatedUserInfo {
    // Get the details of the user and return the info

    // Didn't find anything.
    return nil;
}

+ (BOOL)isAuthenticated {
    // Check if we have any login info
    return NO;
}

+ (void)fetchGooglePlusUserData:(void (^)(NSDictionary *))completed {
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
                NSLog(@"person: %@", person);
                if (completed) {
                    NSString *fullname = @"";
                    if (person.displayName) {
                        fullname = person.displayName;
                    }
                    completed(@{ @"email" : [GPPSignIn sharedInstance].authentication.userEmail,
                                 @"full_name" : fullname });
                }
//                if (error) {
//                    
//                    
//                    
//                    //Handle Error
//                    
//                } else
//                {
//                    self.googlePlusUserInfo = @{
//                                                @"email" : [GPPSignIn sharedInstance].authentication.userEmail,
//                                                @"full_name" : [person.name.givenName stringByAppendingFormat:@" %@",person.name.familyName]
//                                                };
//                    
//                    
//                    // It's possible to retrieve:
//                    // GoogleID with "person.identifier".
//                    // Gender with "person.gender".
//                    
//                    
//                    NSLog(@"User information: %@", self.googlePlusUserInfo);
//                    
//                    
//                }
                
            }];
}


@end
