//
//  AppDelegate.m
//  presentiemeter
//
//  Created by Peter Alserda on 14/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import <GoogleOpenSource/GoogleOpenSource.h>

#import "PMAppDelegate.h"
#import "PMUserLogin.h"
#import "PMBeaconDetector.h"

@interface PMAppDelegate ()

@property (nonatomic, strong) PMBeaconDetector *beaconfinder;

@end

@implementation PMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GPPSignIn sharedInstance].clientID = kClientId;
    [[GPPSignIn sharedInstance] trySilentAuthentication];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    if ([PMUserLogin isAuthenticated]) {
        [self didLogin];
    } else {
        PMLoginViewController *loginvc = [[PMLoginViewController alloc] init];
        loginvc.delegate = self;
        self.window.rootViewController = loginvc;
    }
    
    [self.window makeKeyAndVisible];
    
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
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

#pragma mark - PMLoginViewControllerDelegate methods

- (void)didLogin {
    // The user is authenticated. Show the right view controller.
    
//    self.tabBarController = [[UITabBarController alloc] init];
    
    self.locationViewController = [[PMLocationViewController alloc] initWithNibName:nil bundle:nil];
//    self.beaconActivityViewController = [[PMBeaconActivityViewController alloc] initWithNibName:nil bundle:nil];
    
    UINavigationController *locationNavController = [[UINavigationController alloc] initWithRootViewController:self.locationViewController];
//    UINavigationController *beaconActivityNavController = [[UINavigationController alloc] initWithRootViewController:self.beaconActivityViewController];
    
//    self.tabBarController.viewControllers = @[locationNavController, beaconActivityNavController];
//    self.tabBarController.selectedIndex = 0;

    // Change the appearance of the navigationBar.
    [self configureNavigationBar];
    
//    self.window.rootViewController = self.tabBarController;
    self.window.rootViewController = locationNavController;
    
    self.beaconfinder = [PMBeaconDetector new];
    [self.beaconfinder start];
    
    // Set the beacon detector instance to have logging view
    self.beaconActivityViewController.beaconfinder = self.beaconfinder;
}

- (void)logOut {
    [self.beaconfinder stop];
    PMLoginViewController *loginvc = [[PMLoginViewController alloc] init];
    loginvc.delegate = self;
    self.window.rootViewController = loginvc;
    
    self.locationViewController = nil;
    self.beaconActivityViewController = nil;
    self.tabBarController = nil;
    self.beaconfinder = nil;
}

- (void)configureNavigationBar {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavigationBar"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"ShadowImage"]];
}

@end
