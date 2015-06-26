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
@property (nonatomic, strong) NSMutableDictionary *distancePerRegion;
@property (nonatomic, strong) NSTimer *timeoutTimer;
@property (nonatomic, strong) NSString *closestBeacon;

@end

@implementation PMBeaconDetector

- (instancetype)init {
    self = [super init];
    if (self) {
        self.activeRegions = [[NSMutableArray alloc] init];
        
        /* Used for debugging the activity in PMBeaconActivityViewController */
        self.locations = [NSMutableArray array];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        
        /** Retrieve and store the user data for later use */
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
    
    /*
     * Kontact.io beacon 'QOeM'
     * Vergaderbar
     */
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"b5f961a0-1a7a-11e5-b939-0800200c9a66"] identifier:@"QoeM"];
    beaconRegion.notifyEntryStateOnDisplay = YES;
    [self.locationManager startMonitoringForRegion:beaconRegion];
    
    /*
     * Kontact.io beacon 'vNoE'
     * Hoofdkantoor
     */
    beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"f7826da6-4fa2-4e98-8024-bc5b71e0893e"] identifier:@"vNoE"];
    beaconRegion.notifyEntryStateOnDisplay = YES;
    [self.locationManager startMonitoringForRegion:beaconRegion];
    
    /*
     * Kontact.io beacon 'dr8E'
     * Management
     */
    beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:@"e092725e-726a-4e2f-a0ac-f5f9e10b006f"] identifier:@"dr8E"];
    beaconRegion.notifyEntryStateOnDisplay = YES;
    [self.locationManager startMonitoringForRegion:beaconRegion];
}


#pragma mark - CLLocationManagerDelegate methods

/* Invoked when the authorization status changes for this application. */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"%s, status: %d", __PRETTY_FUNCTION__, status);
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
                /* No need to explicitly request permission in iOS < 8, will happen automatically when starting ranging. */
                
                [self startMonitoringRegions];
                
            } else {
                /* Request permission to use Location Services. (new in iOS 8) */
                
                [self.locationManager requestAlwaysAuthorization];
                
            }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            [self startMonitoringRegions];
            break;
            
        case kCLAuthorizationStatusDenied:
            [self.locations addObject: @"Denied access to location services"];
            break;
            
        case kCLAuthorizationStatusRestricted:
            [self.locations addObject: @"No access to location services"];
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    
    /* If the region is currently inside the users location */
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
        
        /* Range the beacons when more than two regions are active, else just post the only location */
        if (self.activeRegions.count == 0) {
            [self postUnavailability];
        } else if (self.activeRegions.count == 1) {
            [self postFirstLocation];
        } else {
            [self temporaryRangeBeacons];
        }
    }

    /** If the user isn't around any regions or beacons, send unavailability. */
    else {
        [self.locations addObject:[NSString stringWithFormat:@"Region: %@ is Unknown or Outside", region.identifier]];
        if ([self.activeRegions count] == 0) {
            [self postUnavailability];
        }
    }
}


- (void)temporaryRangeBeacons {
    NSSet *regions = [self.locationManager monitoredRegions];
    BOOL didStartRanging = NO;
    for (CLRegion *region in regions) {
        /* Check if all monitored regions are active */
        if ([self.activeRegions containsObject:region.identifier]) {
            if ([self.locationManager.rangedRegions containsObject:region]) {
                /* Do nothing if this region is already being ranged */
                NSLog(@"Already scanning this region: %@", region.identifier);
            } else {
                NSLog(@"Ranging beacons in region: %@", region.identifier);
                [self.locations addObject:[NSString stringWithFormat:@"Ranging beacons in region: %@", region.identifier]];
                
                /** Calls the didRangeBeacons delegate on all active regions for several seconds */
                [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
                didStartRanging = YES;
            }
        }
    }
    
    /* If this region is currently being ranged */
    if (didStartRanging) {
        /* Add a dictionary, in which the distances will be added */
        self.distancePerRegion = [NSMutableDictionary dictionary];
        
        /* Start a timer to evaluate the ranging */
        [self.timeoutTimer invalidate];
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                             target:self
                                                           selector:@selector(stopRangingTimeout:)
                                                           userInfo:nil
                                                            repeats:NO];
    }
}

/* Ranging the beacons in regions */
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    for (CLBeacon *beacon in beacons) {
        NSMutableArray *array = [self.distancePerRegion objectForKey:region.identifier];
        if (array == nil) {
            /* If the array is empty (first time ranging) */
            NSLog(@"Array is nil, adding region: %@", region.identifier);
            if (beacon.accuracy < 0) {
                /* Don't add the distance to the beacon if it's a negative number (temporary connection lost) */
                NSLog(@"beacon.accuracy %f is under 0, don't add", beacon.accuracy);
            }
            else {
                /* Add the region's identifier as a key to the array and add it's distance to it. */
                array = [NSMutableArray arrayWithObject:[NSNumber numberWithDouble:beacon.accuracy]];
                [self.distancePerRegion setObject:array forKey:region.identifier];
            }
            
        } else {
            if (beacon.accuracy < 0) {
                /* Don't add the distance to the beacon if it's a negative number (temporary connection lost) */
                NSLog(@"beacon.accuracy %f is under 0, don't add", beacon.accuracy);
            }
            else {
                /* Add the distance to the beacon to the right key (region identifier) */
                [array addObject:[NSNumber numberWithDouble:beacon.accuracy]];
            }
        }
        NSLog(@"distancePerRegion: %@", self.distancePerRegion);
    }
}

/* Called after recieving the data from ranging the beacons
 This is used to calculate the closest region, which will be sent to the back-end */
- (void)stopRangingTimeout:(NSTimer *)timer {
    
    /* Clear the timeoutTimer for next time */
    self.timeoutTimer = nil;
    
    /* Stop all active scanned regions */
    NSSet *rangingBeacons = self.locationManager.rangedRegions;
    for (CLBeaconRegion *region in rangingBeacons) {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
    
    /* Determine the average for each ranged region */
    for (NSString *regionIdentifier in self.distancePerRegion.allKeys) {
        NSArray *array = [self.distancePerRegion objectForKey:regionIdentifier];
        float total;
        total = 0;
        for(NSNumber *value in array) {
            total += [value floatValue];
        }
        float average = total / array.count;
        
        /* Replace all distances with the average for each region identifier. */
        [self.distancePerRegion setObject:[NSNumber numberWithFloat:average] forKey:regionIdentifier];
    }

    NSLog(@"distancePerRegion with average: %@", self.distancePerRegion);
    
    /* Now compare each average and decide the closest region. */
    NSNumber *closest;
    for (NSString *regionIdentifier in self.distancePerRegion.allKeys) {
        NSNumber *average = [self.distancePerRegion objectForKey:regionIdentifier];
        NSLog(@"average: %@ from ID %@", average, regionIdentifier);
        
        /* Add the first average as the closest. */
        if (!closest) {
            
            NSLog(@"closest is empty, adding %@", average);
            closest = average;
            self.closestBeacon = regionIdentifier;
        } else if ([average compare:closest] == NSOrderedAscending) {
            /* If the next average is higher than the first one, replace it. */
            NSLog(@"%@ is closer than %@, replacing", average, closest);
            closest = average;
            self.closestBeacon = regionIdentifier;
        } else {
            /* If the next average is lower than the first one, do nothing. */
            NSLog(@"%@ is futher away than %@", average, closest);
        }
    }
    
    NSLog(@"closest target: %@", self.closestBeacon);
    
    /* If the closest beacon is still an active region */
    if ([self.activeRegions containsObject:self.closestBeacon]) {
        NSLog(@"Yes, %@ contains %@", self.activeRegions, self.closestBeacon);
        [self.locations addObject:[NSString stringWithFormat:@"Yes, activeRegions contains %@", self.closestBeacon]];
        
        /* POST its location to the back-end. */
        [[PMBackend sharedInstance] updateUserLocation:kPresentiemeterUpdateLocationPath
                                          withLocation:self.closestBeacon
                                           forUsername:self.googlePlusUserInfo[@"full_name"]
                                              andEmail:self.googlePlusUserInfo[@"email"]
                                               success:^(id json) {
                                                   [self.locations addObject:[NSString stringWithFormat:@"Posted closest region: %@", self.closestBeacon]];
                                                   NSLog(@"Posted closest region: %@", self.closestBeacon);
                                                   
                                                   /* Check again if the user left all regions, if so; post unavailability. */
                                                   if ([self.activeRegions count] == 0) {
                                                       [self postUnavailability];
                                                   }
                                                   
                                               } failure:^(NSError *error) {
                                                   [self.locations addObject:[NSString stringWithFormat:@"Posted closest region failed:"]];
                                                   [self.locations addObject:[NSString stringWithFormat:@"%@", error]];
                                                   NSLog(@"Posted closest region failed: %@", error);
                                                   
                                                   /* Check again if the user left all regions, if so; post unavailability. */
                                                   if ([self.activeRegions count] == 0) {
                                                       [self postUnavailability];
                                                   }
                                               }];
    }
    /* If the closest beacon isn't active anymore, do nothing. */
    else {
        NSLog(@"No, %@ does not contain %@", self.activeRegions, self.closestBeacon);
        [self.locations addObject:[NSString stringWithFormat:@"No, activeRegions does not contain %@", self.closestBeacon]];
        
        /* Check again if the user left all regions, if so; post unavailability. */
        if ([self.activeRegions count] == 0) {
            [self postUnavailability];
        }
    }
    
    /* Clear the distances for next time. */
    self.distancePerRegion = nil;
}

/* Invoked when the user enters a monitored region, in which it enters the 'didDetermineState' delegate */
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.locations addObject:[NSString stringWithFormat:@"Entered region: %@", region.identifier]];
}

/* Invoked when a user leaves a monitored region.  */
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.locations addObject:[NSString stringWithFormat:@"Left region: %@", region.identifier]];
    NSLog(@"Exited region: %@", region.identifier);
    
    /* Check if region that the user left is part of the active regions. */
    if ([self.activeRegions containsObject:region.identifier]) {
        /* If so, remove the region from the activeRegions array*/
        [self.activeRegions removeObject:region.identifier];
        [self.locations addObject:[NSString stringWithFormat:@"Removed %@ from activeRegions", region.identifier]];
        [self.locations addObject:[NSString stringWithFormat:@"activeRegions: "]];
        [self.locations addObjectsFromArray:self.activeRegions];
        NSLog(@"Removed %@ from activeRegions", region.identifier);
        NSLog(@"activeRegions after removal: %@", self.activeRegions);
    }

    /** POST unavailability if this was the last active region. If there is one region left, post this address. */
    if (self.activeRegions.count == 0) {
        [self postUnavailability];
    } else if (self.activeRegions.count == 1) {
        [self postFirstLocation];
    }
}

/* Invoked when a monitoring for a region started successfully. */
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region  {
    NSLog(@"%s, region: %@", __PRETTY_FUNCTION__, region);
    [self.locations addObject:[NSString stringWithFormat:@"didStartMonitoring: %@", region.identifier]];
}


/* POST request to the back-end, making the user unavailable. */
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

/* POST request to the back-end, posting the only active region. */
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
