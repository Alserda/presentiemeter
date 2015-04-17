//
//  ViewController.h
//  presentiemeter
//
//  Created by Peter Alserda on 14/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EstimoteSDK/EstimoteSDK.h>
#import <GooglePlus/GooglePlus.h>

typedef enum : int
{
    ESTScanTypeBluetooth,
    ESTScanTypeBeacon
    
} ESTScanType;


@interface PMLocationVC : UITableViewController

/*
 * Selected beacon is returned on given completion handler.
 */
- (id)initWithScanType:(ESTScanType)scanType completion:(void (^)(id))completion;

@end

