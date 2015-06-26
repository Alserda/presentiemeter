//
//  AppDelegate.h
//  presentiemeter
//
//  Created by Peter Alserda on 14/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "PMLoginViewController.h"
#import "PMLocationViewController.h"
#import "PMBeaconActivityViewController.h"

@interface PMAppDelegate : UIResponder <UIApplicationDelegate, PMLoginViewControllerDelegate, CBCentralManagerDelegate>

/** Main UIWindow instance of the application */
@property (strong, nonatomic) UIWindow *window;

/** Main tabBarController for the application */
@property (strong, nonatomic) UITabBarController *tabBarController;

/** Reference to the 'Locations' tab view controller */
@property (strong, nonatomic) PMLocationViewController *locationViewController;

/** Reference to the 'Beacon Activity' tab view controller */
@property (strong, nonatomic) PMBeaconActivityViewController *beaconActivityViewController;

/** For logging out **/
- (void)logOut;

@end

