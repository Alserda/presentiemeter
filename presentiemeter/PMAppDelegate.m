//
//  AppDelegate.m
//  presentiemeter
//
//  Created by Peter Alserda on 14/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import "PMAppDelegate.h"
#import "PMLoginVC.h"
#import "PMLocationVC.h"
#import "PMUserLogin.h"
#import <EstimoteSDK/EstimoteSDK.h>
#import <GooglePlus.h>

#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface PMAppDelegate ()

@end

@implementation PMAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GPPSignIn sharedInstance].clientID = kClientId;
    [[GPPSignIn sharedInstance] trySilentAuthentication];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([PMUserLogin isAuthenticated]) {
        [self didLogin];
    } else {
        PMLoginVC *loginvc = [[PMLoginVC alloc] init];
        loginvc.delegate = self;
        self.window.rootViewController = loginvc;
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    [ESTCloudManager setupAppID:@"app_2f865fbwyx" andAppToken:@"e05409fc493936dd3c279b9563b72e75"];
    [ESTCloudManager enableAnalytics:YES];

    
    // Register for remote notificatons related to Estimote Remote Beacon Management.
    if (IS_OS_8_OR_LATER)
    {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeNone);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        
        [application registerUserNotificationSettings:settings];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeNone];
    }
    
    return YES;
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
//    NSLog(@"applicationWillResignActive");

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    NSLog(@"applicationDidEnterBackground");

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
//    NSLog(@"applicationWillEnterForeground");
    [[GPPSignIn sharedInstance] trySilentAuthentication];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
//    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
//    NSLog(@"applicationWillTerminate");
}

#pragma mark - PMLoginViewControllerDelegate methods

- (void)didLogin {
    // Alright we successfully logged in, lets get to action
    dispatch_async(dispatch_get_main_queue(), ^{
        // Show the right view controller
        PMLocationVC *locationvc = [[PMLocationVC alloc] init];
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:locationvc];
    });
        // Start scanning the beacons
//    [locationvc startScanningOrSomething];
}

@end
