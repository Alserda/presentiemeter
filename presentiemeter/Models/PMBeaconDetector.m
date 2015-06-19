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
        
        /** Retrieve and store the user data */
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
}

- (void)stop {
    for (CLBeaconRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopRangingBeaconsInRegion:region];
        [self.locationManager stopMonitoringForRegion:region];
        NSLog(@"Stopped monitoring: %@", region);
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


#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    
    /** If the region is currently inside the users location */
    if (state == CLRegionStateInside) {
        [self.locations addObject:[NSString stringWithFormat:@"%@ is inside", region.identifier]];
        NSLog(@"%@ is inside", region.identifier);
        
        /** Adds this region to the active regions array, if it doesn't exist yet */
        if (![self.activeRegions containsObject:region.identifier]) {
            [self.activeRegions addObject:region.identifier];
            [self.locations addObject:[NSString stringWithFormat:@"%@ is added to activeRegions", region.identifier]];
            NSLog(@"%@ added to array", region.identifier);
            NSLog(@"activeRegions array: %@", self.activeRegions);
        }
        
        /** Range the beacons when more than two regions are active, else just post the only location */
        if (self.activeRegions.count == 0) {
            [self postUnavailability];
        } else if (self.activeRegions.count == 1) {
            [self postFirstLocation];
        } else {
            [self temporaryRangeBeacons];
        }
    }

    /** If the region is Outside the current location, or Unknown */
    else {
        [self.locations addObject:[NSString stringWithFormat:@"Region: %@ is Unknown or Outside", region.identifier]];
        if ([self.activeRegions count] == 0) {
            [self postUnavailability];
        }
    }
}


/** Calls the didRangeBeacons delegate on all active regions for several seconds */
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

/** Called after recieving the data from ranging the beacons
 This is used to calculate the closest region, which will be sent to the back-end*/
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
            total += [value floatValue];
        }
        
        float average = total / array.count;
        
        [self.rangedRegions setObject:[NSNumber numberWithFloat:average] forKey:regionIdentifier];
    }

    NSLog(@"rangedRegions with average: %@", self.rangedRegions);
    
    // Now decide which beacon is closest
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
        } else {
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
                                                   if ([self.activeRegions count] == 0) {
                                                       [self postUnavailability];
                                                   }
                                               } failure:^(NSError *error) {
                                                   [self.locations addObject:[NSString stringWithFormat:@"Posted closest region failed:"]];
                                                   [self.locations addObject:[NSString stringWithFormat:@"%@", error]];
                                                   NSLog(@"Posted closest region failed: %@", error);
                                                   if ([self.activeRegions count] == 0) {
                                                       [self postUnavailability];
                                                   }
                                               }];
    }
    else {
        NSLog(@"No, %@ does not contain %@", self.activeRegions, self.closestBeacon);
        [self.locations addObject:[NSString stringWithFormat:@"No, activeRegions does not contain %@", self.closestBeacon]];
        if ([self.activeRegions count] == 0) {
            [self postUnavailability];
        }
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

    /** Range the beacons when more than two regions are active, else just post the only location */
    if (self.activeRegions.count == 0) {
        [self postUnavailability];
    } else if (self.activeRegions.count == 1) {
        [self postFirstLocation];
    }
}

/*
 *  locationManager:didChangeAuthorizationStatus:
 *
 *  Discussion:
 *    Invoked when the authorization status changes for this application.
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"%s, status: %d", __PRETTY_FUNCTION__, status);
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
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
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            [self startMonitoringRegions];
        }
            break;
            
        case kCLAuthorizationStatusDenied:
        {
            [self.locations addObject: @"Denied access to location services"];
        }
            break;
        
        case kCLAuthorizationStatusRestricted:
        {
            [self.locations addObject: @"No access to location services"];
        }
            break;
            
        default:
            break;
    }    
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


- (void)postUnavailability {
    [[PMBackend sharedInstance] updateUnavailableLocation:kPresentiemeterUpdateUnavailablePath
                                                withEmail:self.googlePlusUserInfo[@"email"]
                                              forUsername:self.googlePlusUserInfo[@"full_name"]
                                                  success:^(id json) {
                                                      [self.locations addObject:[NSString stringWithFormat:@"Unavailable POST successful"]];
                                                      NSLog(@"Unavailable POST successful");
                                                  } failure:^(NSError *error) {
                                                      [self.locations addObject:[NSString stringWithFormat:@"Unavailable POST failed: "]];
                                                      [self.locations addObject:[NSString stringWithFormat:@"%@", error]];
                                                      NSLog(@"Unavailable POST failed: %@", error);
                                                  }];
}

- (void)postFirstLocation {
        [[PMBackend sharedInstance] updateUserLocation:kPresentiemeterUpdateLocationPath
                                          withLocation:self.activeRegions.firstObject
                                           forUsername:self.googlePlusUserInfo[@"full_name"]
                                              andEmail:self.googlePlusUserInfo[@"email"]
                                               success:^(id json) {
                                                   [self.locations addObject:[NSString stringWithFormat:@"Only region %@ is the new location", self.activeRegions.firstObject]];
                                               } failure:^(NSError *error) {
                                                   [self.locations addObject:[NSString stringWithFormat:@"Only region post failed:"]];
                                                   [self.locations addObject:[NSString stringWithFormat:@"%@", error]];
                                               }];
}

@end
