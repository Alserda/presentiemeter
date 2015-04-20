//
//  AppDelegate.h
//  presentiemeter
//
//  Created by Peter Alserda on 14/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EstimoteSDK/EstimoteSDK.h>

#import "PMLoginVC.h"

@interface PMAppDelegate : UIResponder <UIApplicationDelegate, PMLoginViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

