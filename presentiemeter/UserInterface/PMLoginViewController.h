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

/** Called on the delegate when user login was successfull */
- (void)didLogin;

@end

static NSString * const kClientId = @"710333786173-t904e7mn0u7dqgv53lh4cqbpgo8nfcpe.apps.googleusercontent.com";

@class GPPSignInButton;

@interface PMLoginViewController : UIViewController <GPPSignInDelegate, MKMapViewDelegate,  CLLocationManagerDelegate>

@property (strong, nonatomic) UIView *informationContainer;
@property (strong, nonatomic) UIView *signInContainer;

/** Delegate handling the login success situation */
@property (nonatomic, weak) id<PMLoginViewControllerDelegate> delegate;

@property (strong, nonatomic) GPPSignInButton *googlePlusSignInButton;


@property(nonatomic, strong) MKMapView *mapView;
@property(nonatomic, strong) CLLocationManager *locationManager;

@end
