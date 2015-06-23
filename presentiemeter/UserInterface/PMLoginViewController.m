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
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    
    signIn.clientID = kClientId;
    
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    signIn.scopes = @[ @"profile" ];
    signIn.delegate = self;
    
    
    [self addMapView];
    [self addSignInContainer];
    [self addLogo];
    [self addSignInButton];
}

- (void)addMapView {
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 115)];
    
    self.mapView.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    #ifdef __IPHONE_8_0
        if(IS_OS_8_OR_LATER) {
            [self.locationManager requestAlwaysAuthorization];
        }
    #endif
    
    
    

    self.mapView.mapType = MKMapTypeSatellite;
    self.mapView.zoomEnabled = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.pitchEnabled = YES;
    self.mapView.rotateEnabled = YES;

    self.mapView.showsUserLocation = YES;
    
    [self.locationManager startUpdatingLocation];
    
    [self.view addSubview:self.mapView];
}

- (void)addSignInContainer {
    self.signInContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mapView.bounds), self.view.frame.size.width, 115)];
    self.signInContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.signInContainer];
}

- (void)addLogo {
    UIImageView *peperzakenLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"peperzaken"]];
    peperzakenLogo.frame = CGRectMake(0, 0, 277, 67);
    peperzakenLogo.center = CGPointMake(self.mapView.frame.size.width / 2, self.mapView.frame.size.height / 2);
    
    [self.mapView addSubview:peperzakenLogo];
}

- (void)addSignInButton {
    _googlePlusSignInButton = [GPPSignInButton buttonWithType:UIButtonTypeCustom];
    _googlePlusSignInButton.style = kGPPSignInButtonStyleWide;
    _googlePlusSignInButton.colorScheme = kGPPSignInButtonColorSchemeDark;
    _googlePlusSignInButton.center = CGPointMake(self.signInContainer.frame.size.width / 2, self.signInContainer.frame.size.height / 2);
    
    [self.signInContainer addSubview:_googlePlusSignInButton];
}

- (void)paddingTextField:(UITextField *)textField {
    UIView*leftPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    textField.leftView = leftPadding;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        NSLog(@"Error bij finishedWithAuth");
    } else {
        [self refreshInterfaceBasedOnSignIn];
    }
}

-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        if ([self.delegate respondsToSelector:@selector(didLogin)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate performSelector:@selector(didLogin)];
            });
        }
    } else {
        self.googlePlusSignInButton.hidden = NO;
        NSLog(@"Google button hidden = NO");
        // Perform other actions here
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
//    CLLocationCoordinate2D userCoordinate = CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
//    
//    NSLog(@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
//    
//    CLLocationCoordinate2D eyecoordinate = CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude - 0.021, self.locationManager.location.coordinate.longitude - 0.05);
//    
//    MKMapCamera *mapCamera = [MKMapCamera cameraLookingAtCenterCoordinate:userCoordinate fromEyeCoordinate:eyecoordinate eyeAltitude:400.0];
//    
//    [self.mapView setCamera:mapCamera animated:YES];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    NSLog(@"Updated location");
}

- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *ulv = [mapView viewForAnnotation:mapView.userLocation];
    ulv.hidden = YES;
}

@end
