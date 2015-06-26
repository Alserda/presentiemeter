//
//  PMLoginVC.m
//  presentiemeter
//
//  Created by Peter Alserda on 17/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import "PMLoginViewController.h"
#import "PMLocationViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>

@implementation PMLoginViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    /* Decide which data the app has to fetch from the users Google+ account. */
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = kClientId;
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    signIn.scopes = @[ @"profile" ];
    signIn.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    /* If the device has iOS 8.0+, ask for authorization. */
    #ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
    }
    #endif
    [self.locationManager startUpdatingLocation];
    
    /* Add all components to the view */
    [self addMapView];
    [self addSignInContainer];
    [self addLogo];
    [self addSignInButton];
}

/* Add the view containing the world map. */
- (void)addMapView {
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 115)];
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeSatellite;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.pitchEnabled = YES;
    self.mapView.rotateEnabled = YES;
    self.mapView.showsUserLocation = YES;
    [self.view addSubview:self.mapView];
}

/* Add the container, containing the log-in button. */
- (void)addSignInContainer {
    self.signInContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mapView.bounds), self.view.frame.size.width, 115)];
    self.signInContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.signInContainer];
}

/* Add the logo to the mapview. */
- (void)addLogo {
    UIImageView *peperzakenLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"peperzaken"]];
    peperzakenLogo.frame = CGRectMake(0, 0, 277, 67);
    peperzakenLogo.center = CGPointMake(self.mapView.frame.size.width / 2, self.mapView.frame.size.height / 2);
    [self.mapView addSubview:peperzakenLogo];
}

/* Add the google sign in button to the sign in container. */
- (void)addSignInButton {
    _googlePlusSignInButton = [GPPSignInButton buttonWithType:UIButtonTypeCustom];
    _googlePlusSignInButton.style = kGPPSignInButtonStyleWide;
    _googlePlusSignInButton.colorScheme = kGPPSignInButtonColorSchemeDark;
    _googlePlusSignInButton.center = CGPointMake(self.signInContainer.frame.size.width / 2, self.signInContainer.frame.size.height / 2);
    [self.signInContainer addSubview:_googlePlusSignInButton];
}

/* Handler for processing authentication, after agreeing on sharing google's info. */
- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        NSLog(@"Error bij finishedWithAuth");
    } else {
        [self refreshInterfaceBasedOnSignIn];
    }
}

/* Show different views, when signing in succesfully. */
- (void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        if ([self.delegate respondsToSelector:@selector(didLogin)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate performSelector:@selector(didLogin)];
            });
        }
    } else {
        NSLog(@"Failed. ");
        // Perform other actions here
    }
}

/* Invoked when the app updates the users location. */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    /* Zoom in on the users location. */
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    NSLog(@"Updated location");
}

/* Remove the blue circle, which appears on the users location. */
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *ulv = [mapView viewForAnnotation:mapView.userLocation];
    ulv.hidden = YES;
}

@end
