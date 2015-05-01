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

@property (nonatomic, strong) NSMutableArray *locations;

- (void)start;

@end
