//
//  PMBeaconDetector.m
//  presentiemeter
//
//  Created by Peter Alserda on 01/05/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import "PMBeaconDetector.h"
#import "PMBackend.h"
#import "PMUserLogin.h"

@interface PMBeaconDetector ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSDictionary *googlePlusUserInfo;

@end

@implementation PMBeaconDetector

- (instancetype)init {
    self = [super init];
    if (self) {
        NSLog(@"Ranging Available: %@", [CLLocationManager isRangingAvailable] ? @"YES":@"NO");
        NSLog(@"Monitoring available: %@", [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]] ? @"YES":@"NO");
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        self.locations = [NSMutableArray array];
        
        self.googlePlusUserInfo = [PMUserLogin authenticatedUserInfo];
        if (self.googlePlusUserInfo == nil) {
            [PMUserLogin fetchGooglePlusUserData:^(NSDictionary *googleUserInfo) {
                NSLog(@"received userinfo: %@", googleUserInfo);
                self.googlePlusUserInfo = googleUserInfo;
            }];
        }
    }
    return self;
}

- (void)start {
    [self.locationManager requestAlwaysAuthorization];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            /*
             * No need to explicitly request permission in iOS < 8, will happen automatically when starting ranging.
             //             */
            CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"] major:52064 minor:11111 identifier:@"C2:E9:12:49:CB:60"];
            beaconRegion.notifyEntryStateOnDisplay = YES;
            [self.locationManager startMonitoringForRegion:beaconRegion];
            
            beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"] major:15687 minor:12845 identifier:@"C2:4C:32:2D:3D:47"];
            beaconRegion.notifyEntryStateOnDisplay = YES;
            [self.locationManager startMonitoringForRegion:beaconRegion];
        } else {
            /*
             * Request permission to use Location Services. (new in iOS 8)
             * We ask for "always" authorization so that the Notification Demo can benefit as well.
             * Also requires NSLocationAlwaysUsageDescription in Info.plist file.
             *
             * For more details about the new Location Services authorization model refer to:
             * https://community.estimote.com/hc/en-us/articles/203393036-Estimote-SDK-and-iOS-8-Location-Services
             */
            
            [self.locationManager requestAlwaysAuthorization];
            
        }
    }
    else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"] major:52064 minor:11111 identifier:@"C2:E9:12:49:CB:60"];
        beaconRegion.notifyEntryStateOnDisplay = YES;
        [self.locationManager startMonitoringForRegion:beaconRegion];
        
        beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"] major:15687 minor:12845 identifier:@"C2:4C:32:2D:3D:47"];
        beaconRegion.notifyEntryStateOnDisplay = YES;
        [self.locationManager startMonitoringForRegion:beaconRegion];
    }
    else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        [self.locations addObject: @"Denied access to location services"];
    }
    else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        [self.locations addObject: @"No access to location services"];
    }
    
}


#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSLog(@"Monitored Regions: %@", self.locationManager.monitoredRegions);
//    NSLog(@"%s, state: %d, region: %@", __PRETTY_FUNCTION__, state, region);


    if (state == CLRegionStateInside) {
//        [self.locations addObject:[NSString stringWithFormat:@"Inside region: %@", region.identifier]];
        [[PMBackend sharedInstance] updateUserLocation:kPresentiemeterUpdateLocationPath
                                                   withLocation:region.identifier
                                                    forUsername:self.googlePlusUserInfo[@"full_name"]
                                                       andEmail:self.googlePlusUserInfo[@"email"]
                                                        success:^(id json) {
                                                                [self.locations addObject:[NSString stringWithFormat:@"POST successful to: %@", region.identifier]];
                                                            } failure:^(NSError *error) {
                                                                   [self.locations addObject:[NSString stringWithFormat:@"POST failed to %@", region.identifier]];
                                                                }];
    }
    else {
        [self.locations addObject:[NSString stringWithFormat:@"Region: %@, state5: %d", region.identifier, state]];
    }
//    if ([region isKindOfClass:[CLBeaconRegion class]]) {
//                [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
//    }
}

/*
 *  locationManager:didRangeBeacons:inRegion:
 *
 *  Discussion:
 *    Invoked when a new set of beacons are available in the specified region.
 *    beacons is an array of CLBeacon objects.
 *    If beacons is empty, it may be assumed no beacons that match the specified region are nearby.
 *    Similarly if a specific beacon no longer appears in beacons, it may be assumed the beacon is no longer received
 *    by the device.
 */
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"%s, beacons: %@", __PRETTY_FUNCTION__, beacons);
}

/*
 *  locationManager:rangingBeaconsDidFailForRegion:withError:
 *
 *  Discussion:
 *    Invoked when an error has occurred ranging beacons in a region. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

/*
 *  locationManager:didEnterRegion:
 *
 *  Discussion:
 *    Invoked when the user enters a monitored region.  This callback will be invoked for every allocated
 *    CLLocationManager instance with a non-nil delegate that implements this method.
 */
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.locations addObject:[NSString stringWithFormat:@"Entered region: %@", region.identifier]];
}
/*
 *  locationManager:didExitRegion:
 *
 *  Discussion:
 *    Invoked when the user exits a monitored region.  This callback will be invoked for every allocated
 *    CLLocationManager instance with a non-nil delegate that implements this method.
 */
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.locations addObject:[NSString stringWithFormat:@"Left region: %@", region.identifier]];
    [[PMBackend sharedInstance] updateUnavailableLocation:kPresentiemeterUpdateUnavailablePath
                                                withEmail:self.googlePlusUserInfo[@"email"]
                                              forUsername:self.googlePlusUserInfo[@"full_name"]
                                                  success:^(id json) {
                                                      [self.locations addObject:[NSString stringWithFormat:@"Unavailable POST successfull %@", region.identifier]];
                                                  } failure:^(NSError *error) {
                                                      [self.locations addObject:[NSString stringWithFormat:@"Unavailable POST failed  %@", region.identifier]];
                                                  }];
}

/*
 *  locationManager:didFailWithError:
 *
 *  Discussion:
 *    Invoked when an error has occurred. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

/*
 *  locationManager:monitoringDidFailForRegion:withError:
 *
 *  Discussion:
 *    Invoked when a region monitoring error has occurred. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region
              withError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

/*
 *  locationManager:didChangeAuthorizationStatus:
 *
 *  Discussion:
 *    Invoked when the authorization status changes for this application.
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"%s, status: %d", __PRETTY_FUNCTION__, status);
}

/*
 *  locationManager:didStartMonitoringForRegion:
 *
 *  Discussion:
 *    Invoked when a monitoring for a region started successfully.
 */
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region  {
    NSLog(@"%s, region: %@", __PRETTY_FUNCTION__, region);
    [self.locations addObject:[NSString stringWithFormat:@"didStartMonitoring: %@", region.identifier]];
}

/*
 *  locationManager:didVisit:
 *
 *  Discussion:
 *    Invoked when the CLLocationManager determines that the device has visited
 *    a location, if visit monitoring is currently started (possibly from a
 *    prior launch).
 */
- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
