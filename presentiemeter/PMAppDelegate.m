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
@property (nonatomic, strong) CBCentralManager *bluetoothManager;

@end

@implementation PMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /* Check if there's a session and try to authenticate with it
     So users stay logged in when reopening the app.. */
    [GPPSignIn sharedInstance].clientID = kClientId;
    [[GPPSignIn sharedInstance] trySilentAuthentication];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([PMUserLogin isAuthenticated]) {
        /** Go to the main screen. **/
        [self didLogin];
    } else {
        /** Show the log-in screen. **/
        PMLoginViewController *loginvc = [[PMLoginViewController alloc] init];
        loginvc.delegate = self;
        self.window.rootViewController = loginvc;
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


/* Handler for google sign-in, which sends you to your browser */
- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}


/* Detect is Bluetooth is enabled */
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self detectBluetooth];
}


#pragma mark - PMLoginViewControllerDelegate methods

- (void)didLogin {
    /** The user is authenticated. Show the right view controller. **/
    self.locationViewController = [[PMLocationViewController alloc] initWithNibName:nil bundle:nil];
    
    UINavigationController *locationNavController = [[UINavigationController alloc] initWithRootViewController:self.locationViewController];
    self.window.rootViewController = locationNavController;
    
    /** Change the appearance of the navigationBar. **/
    [self configureNavigationBar];
    
    /** Start the beacon scanner **/
    self.beaconfinder = [PMBeaconDetector new];
    [self.beaconfinder start];
}

- (void)logOut {
    /* Stop scanning for beacons */
    [self.beaconfinder stop];
    
    /* Show the login-screen view */
    PMLoginViewController *loginvc = [[PMLoginViewController alloc] init];
    loginvc.delegate = self;
    self.window.rootViewController = loginvc;
    
    /* Remove other views */
    self.locationViewController = nil;
    self.beaconActivityViewController = nil;
    self.tabBarController = nil;
    self.beaconfinder = nil;
}

- (void)configureNavigationBar {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavigationBar"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"ShadowImage"]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)detectBluetooth {
    /* Create a bluetooth manager and run it */
    self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                 queue:nil
                                                               options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                                                                   forKey:CBCentralManagerOptionShowPowerAlertKey]];
    [self centralManagerDidUpdateState:self.bluetoothManager];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *stateString = nil;
    BOOL stateTriggered = NO;
    
    /* Switch through the possible Bluetooth states */
    switch(central.state) {
        case CBCentralManagerStateResetting:
            stateString = @"The connection with the system service was momentarily lost, update imminent.";
            stateTriggered = YES;
            break;
        case CBCentralManagerStateUnsupported:
            stateString = @"The platform doesn't support Bluetooth Low Energy. Beacon detection won't work. ";
            stateTriggered = YES;
            break;
        case CBCentralManagerStateUnauthorized:
            stateString = @"The app is not authorized to use Bluetooth Low Energy. Beacon detection won't work. ";
            stateTriggered = YES;
            break;
        case CBCentralManagerStatePoweredOff:
            stateString = @"Bluetooth is currently powered off. Beacon detection won't work. ";
            stateTriggered = YES;
            break;
        default:
            break;
    }
    
    /* If any of the above states have been triggered, display the message. */
    if (stateTriggered == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth state"
                                                        message:stateString
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
}

@end
