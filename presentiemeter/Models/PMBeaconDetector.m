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
@property (nonatomic, strong) NSMutableArray *activeRegions;
@property (nonatomic, strong) NSMutableDictionary *rangedRegions;
@property (nonatomic, strong) NSTimer *timeoutTimer;
@property (nonatomic, strong) NSString *closestBeacon;

@end

@implementation PMBeaconDetector

- (instancetype)init {
    self = [super init];
    if (self) {
        NSLog(@"Ranging Available: %@", [CLLocationManager isRangingAvailable] ? @"YES":@"NO");
        NSLog(@"Monitoring available: %@", [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]] ? @"YES":@"NO");
        self.activeRegions = [[NSMutableArray alloc] init];
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
            */
            
            [self startMonitoringRegions];
            
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
        [self startMonitoringRegions];
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
    
    if (state == CLRegionStateInside) {
        [self.locations addObject:[NSString stringWithFormat:@"%@ is inside", region.identifier]];
        NSLog(@"%@ is inside", region.identifier);
        
        // Checks if the identifier of the inside-region is equal to one of the monitored regions
        NSSet *identifiers = [self.locationManager.monitoredRegions valueForKey:@"identifier"];
        BOOL containsIdentifier = [identifiers containsObject:region.identifier];

        // If the monitored regions do contain an identifier equal to the inside-region's identifier...
        if(containsIdentifier) {
            // Checks if the identifier of the region already exists in the array of registered regions.
            BOOL containsRegion = [self.activeRegions containsObject:region.identifier];

            if (containsRegion) {
                NSLog(@"%@ already contains %@", self.activeRegions, region.identifier);
                
                if (self.activeRegions.count >= 2) {
                    [self temporaryRangeBeacons];
                }
                
                else if (self.activeRegions.count == 1) {
                    // Post the identifier to the back-end to update your current location.
                    [[PMBackend sharedInstance] updateUserLocation:kPresentiemeterUpdateLocationPath
                                                      withLocation:self.activeRegions.firstObject
                                                       forUsername:self.googlePlusUserInfo[@"full_name"]
                                                          andEmail:self.googlePlusUserInfo[@"email"]
                                                           success:^(id json) {
                                                               [self.locations addObject:[NSString stringWithFormat:@"Only region %@ is the new location", self.activeRegions.firstObject]];
                                                           } failure:^(NSError *error) {
                                                               [self.locations addObject:[NSString stringWithFormat:@"Only region %@ post failed", region.identifier]];
                                                           }];
                    
                    
                    
                }
            }
            // If it does not exist, add the identifier.
            else {
                [self.activeRegions addObject:region.identifier];
                [self.locations addObject:[NSString stringWithFormat:@"%@ is added to activeRegions", region.identifier]];
                NSLog(@"%@ added to array", region.identifier);
                
                NSLog(@"activeRegions array: %@", self.activeRegions);
                
                if (self.activeRegions.count == 1) {
                    // Post the identifier to the back-end to update your current location.
                    [[PMBackend sharedInstance] updateUserLocation:kPresentiemeterUpdateLocationPath
                                                      withLocation:self.activeRegions.firstObject
                                                       forUsername:self.googlePlusUserInfo[@"full_name"]
                                                          andEmail:self.googlePlusUserInfo[@"email"]
                                                           success:^(id json) {
                                                               [self.locations addObject:[NSString stringWithFormat:@"First region added %@ is the new location", self.activeRegions.firstObject]];
                                                           } failure:^(NSError *error) {
                                                               [self.locations addObject:[NSString stringWithFormat:@"First region added %@ post failed", region.identifier]];
                                                           }];

                }
                
                if (self.activeRegions.count >= 2) {
                    [self temporaryRangeBeacons];
                }
                
                
            }
//            [self.locations addObjectsFromArray:self.activeRegions];
            
        }
        // The monitored regions don't contain this identifier.
        else {
            NSLog(@"Does not contain identifier: %@", region.identifier);
        }
    }
    
    // The region is either Outside the current location, or Unknown.
    else {
        [self.locations addObject:[NSString stringWithFormat:@"Region: %@ is Unknown or Outside", region.identifier]];
        
        // Decide whether to post unavailability or the remaining object
        
        if ([self.activeRegions count] == 0) {
            [[PMBackend sharedInstance] updateUnavailableLocation:kPresentiemeterUpdateUnavailablePath
                                                        withEmail:self.googlePlusUserInfo[@"email"]
                                                      forUsername:self.googlePlusUserInfo[@"full_name"]
                                                          success:^(id json) {
                                                              [self.locations addObject:[NSString stringWithFormat:@"Unavailable POST successful %@", region.identifier]];
                                                              NSLog(@"Unavailable POST successful %@", region.identifier);
                                                          } failure:^(NSError *error) {
                                                              [self.locations addObject:[NSString stringWithFormat:@"Unavailable POST failed  %@", region.identifier]];
                                                              NSLog(@"Unavailable POST failed: %@", error);
                                                          }];
        }
    }
}

- (void)startMonitoringRegions {
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"] identifier:@"C2:E9:12:49:CB:60"];
    beaconRegion.notifyEntryStateOnDisplay = YES;
    [self.locationManager startMonitoringForRegion:beaconRegion];

    beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"A6B765FA-052C-4F13-B13C-C681E2B27AA6"] identifier:@"C2:4C:32:2D:3D:47"];
    beaconRegion.notifyEntryStateOnDisplay = YES;
    [self.locationManager startMonitoringForRegion:beaconRegion];
    
    beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"e092725e-726a-4e2f-a0ac-f5f9e10b006f"] identifier:@"dr8E"];
    beaconRegion.notifyEntryStateOnDisplay = YES;
    [self.locationManager startMonitoringForRegion:beaconRegion];
}

- (void)temporaryRangeBeacons {
    NSSet *regions = [self.locationManager monitoredRegions];
    BOOL didStartRanging = NO;
    for (CLRegion *region in regions) {
        if ([self.activeRegions containsObject:region.identifier]) {
            if ([self.locationManager.rangedRegions containsObject:region]) {
                NSLog(@"Already scanning this region: %@", region.identifier);
            } else {
                NSLog(@"Ranging beacons in region: %@", region.identifier);
                [self.locations addObject:[NSString stringWithFormat:@"Ranging beacons in region: %@", region.identifier]];
                [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
                didStartRanging = YES;
            }
        }
    }
    
    if (didStartRanging) {
        self.rangedRegions = [NSMutableDictionary dictionary];
        [self.timeoutTimer invalidate];
        // Start a timer to evaluate the ranging
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                             target:self
                                                           selector:@selector(stopRangingTimeout:)
                                                           userInfo:nil
                                                            repeats:NO];
    }
}

- (void)stopRangingTimeout:(NSTimer *)timer {
    self.timeoutTimer = nil;
    // First stop all active scanned regions
    NSSet *rangingBeacons = self.locationManager.rangedRegions;
    for (CLBeaconRegion *region in rangingBeacons) {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
    
    // Now determine the average for the ranged regions
    for (NSString *regionIdentifier in self.rangedRegions.allKeys) {
        NSArray *array = [self.rangedRegions objectForKey:regionIdentifier];
        float total;
        total = 0;
        for(NSNumber *value in array) {
            total+=[value floatValue];
        }
        
        float average = total/array.count;
        
        [self.rangedRegions setObject:[NSNumber numberWithFloat:average] forKey:regionIdentifier];
    }

    //
    NSLog(@"rangedRegions with average: %@", self.rangedRegions);
    NSNumber *closest;
    
    for (NSString *regionIdentifier in self.rangedRegions.allKeys) {
        NSNumber *average = [self.rangedRegions objectForKey:regionIdentifier];
        NSLog(@"average: %@ from ID %@", average, regionIdentifier);
        // Compare each number and decide the closest
        
        
        if (!closest) {
            NSLog(@"closest is empty, adding %@", average);
            closest = average;
            self.closestBeacon = regionIdentifier;
        }
        else if ([average compare:closest] == NSOrderedAscending) {
            NSLog(@"%@ is closer than %@, replacing", average, closest);
            closest = average;
            self.closestBeacon = regionIdentifier;
        }
        else {
            NSLog(@"%@ is futher away than %@", average, closest);
        }
        
        
    }
    
    NSLog(@"closest target: %@", self.closestBeacon);
    
    if ([self.activeRegions containsObject:self.closestBeacon]) {
        NSLog(@"Yes, %@ contains %@", self.activeRegions, self.closestBeacon);
        [self.locations addObject:[NSString stringWithFormat:@"Yes, activeRegions contains %@", self.closestBeacon]];
        
        [[PMBackend sharedInstance] updateUserLocation:kPresentiemeterUpdateLocationPath
                                          withLocation:self.closestBeacon
                                           forUsername:self.googlePlusUserInfo[@"full_name"]
                                              andEmail:self.googlePlusUserInfo[@"email"]
                                               success:^(id json) {
                                                   [self.locations addObject:[NSString stringWithFormat:@"Posted closest region: %@", self.closestBeacon]];
                                                   NSLog(@"Posted closest region: %@", self.closestBeacon);
                                               } failure:^(NSError *error) {
                                                   [self.locations addObject:[NSString stringWithFormat:@"Posted closest region failed: %@", error]];
                                                   NSLog(@"Posted closest region failed: %@", error);
                                               }];
    }
    else {
        NSLog(@"No, %@ does not contain %@", self.activeRegions, self.closestBeacon);
        [self.locations addObject:[NSString stringWithFormat:@"No, activeRegions does not contain %@", self.closestBeacon]];
    }
    
    self.rangedRegions = nil;
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
    for (CLBeacon *beacon in beacons) {
        NSMutableArray *array = [self.rangedRegions objectForKey:region.identifier];
        if (array == nil) {
            NSLog(@"Array is nil, adding region: %@", region.identifier);
            if (beacon.accuracy < 0) {
                NSLog(@"beacon.accuracy %f is under 0, don't add", beacon.accuracy);
            }
            else {
                array = [NSMutableArray arrayWithObject:[NSNumber numberWithDouble:beacon.accuracy]];
                [self.rangedRegions setObject:array forKey:region.identifier];
            }
            
        } else {
            if (beacon.accuracy < 0) {
                NSLog(@"beacon.accuracy %f is under 0, don't add", beacon.accuracy);
            }
            else {
                [array addObject:[NSNumber numberWithDouble:beacon.accuracy]];
            }
        }
        NSLog(@"rangedRegions: %@", self.rangedRegions);
    }
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
    NSLog(@"Exited region: %@", region.identifier);
    
    if ([self.activeRegions containsObject:region.identifier]) {
        [self.activeRegions removeObject:region.identifier];
        [self.locations addObject:[NSString stringWithFormat:@"Removed %@ from activeRegions", region.identifier]];
        [self.locations addObject:[NSString stringWithFormat:@"activeRegions: "]];
        [self.locations addObjectsFromArray:self.activeRegions];
        NSLog(@"Removed %@ from activeRegions", region.identifier);
        NSLog(@"activeRegions after removal: %@", self.activeRegions);
    }
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

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_10_6, __MAC_NA, __IPHONE_2_0, __IPHONE_6_0); {
    NSLog(@"%s, newLocation %@, oldLocation %@", __PRETTY_FUNCTION__, newLocation, oldLocation);
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_6_0); {
    NSLog(@"%s, didUpdateLocations: %@", __PRETTY_FUNCTION__, locations);
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_6_0); {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_6_0); {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)locationManager:(CLLocationManager *)manager
didFinishDeferredUpdatesWithError:(NSError *)error __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_6_0); {
    NSLog(@"%s, error: %@", __PRETTY_FUNCTION__, error);
}

@end