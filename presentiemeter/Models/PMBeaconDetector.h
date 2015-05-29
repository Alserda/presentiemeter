//
//  PMBeaconDetector.h
//  presentiemeter
//
//  Created by Peter Alserda on 01/05/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PMBeaconDetector : NSObject <CLLocationManagerDelegate>

/** Used for debugging the beacondetector */
@property (nonatomic, strong) NSMutableArray *locations;

/** Starts running the beacon detector */
- (void)start;

/** For stopping the monitoring process */
- (void)stop;

@end
