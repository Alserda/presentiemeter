//
//  PMLoginVC.h
//  presentiemeter
//
//  Created by Peter Alserda on 17/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@protocol PMLoginViewControllerDelegate <NSObject>

/** Called on the delegate when user login was successful */
- (void)didLogin;

@end

/* The client ID to access Google's API */
static NSString * const kClientId = @"710333786173-t904e7mn0u7dqgv53lh4cqbpgo8nfcpe.apps.googleusercontent.com";

@class GPPSignInButton;

@interface PMLoginViewController : UIViewController <GPPSignInDelegate, MKMapViewDelegate,  CLLocationManagerDelegate>

/* Delegate handling the login success situation */
@property (nonatomic, weak) id<PMLoginViewControllerDelegate> delegate;

/* Sign-in button */
@property (nonatomic, strong) GPPSignInButton *googlePlusSignInButton;

/* The view containing the map. */
@property (nonatomic, strong) MKMapView *mapView;

/* A locationManager to handle the locations of the user. */
@property (nonatomic, strong) CLLocationManager *locationManager;

/* The bottom container in which the log-in button is shown. */
@property (nonatomic, strong) UIView *signInContainer;

@end
