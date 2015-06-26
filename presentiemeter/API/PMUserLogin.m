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
#import "PMLoginViewController.h"

/** This class is used to validate a GooglePlus account
 It's used to store the user data */
@implementation PMUserLogin


/** Get the details of the user and return the info */
+ (NSDictionary *)authenticatedUserInfo {
    NSString *useremail = [[NSUserDefaults standardUserDefaults] objectForKey:@"user-email"];
    NSString *userfullname = [[NSUserDefaults standardUserDefaults] objectForKey:@"user-fullname"];
    
    /** If an email and username exist, return these in a dictionary */
    if (useremail && userfullname) {
        return @{ @"email" : useremail,
                  @"full_name" : userfullname };
    }
    
    /** If nothing is found, return nothing */
    return nil;
}

+ (void)signOut {
    /* Remove the Google session */
    [[GPPSignIn sharedInstance] signOut];
    [[GPPSignIn sharedInstance] disconnect];
    
    /* Clear the user defaults */
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}

/** Check if we have any login info */
+ (BOOL)isAuthenticated {
    return [PMUserLogin authenticatedUserInfo] != nil;
}

/** Create a service instance to send a request to Google+. */
+ (void)fetchGooglePlusUserData:(void (^)(NSDictionary *))completed {
    GTLServicePlus *plusService = [[GTLServicePlus alloc] init];
    [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
    plusService.retryEnabled = YES;
    plusService.apiVersion = @"v1";
    
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
                
                NSLog(@"person: %@", person);

        if (completed) {
            
            /* Define the users full name */
            NSString *fullname = @"";
            if (person.displayName) {
                fullname = person.displayName;
            }
            
            /* Store the user's login-info to the user defaults. */
            [[NSUserDefaults standardUserDefaults] setObject:[GPPSignIn sharedInstance].authentication.userEmail forKey:@"user-email"];
            [[NSUserDefaults standardUserDefaults] setObject:fullname forKey:@"user-fullname"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            /* Define the users email */
            NSString *email = [GPPSignIn sharedInstance].authentication.userEmail;
            if (email == nil) {
                email = @"";
            }
            
            /* Return the email and full_name */
            completed(@{ @"email" : email,
                         @"full_name" : fullname });
        }
    }];
}


@end
