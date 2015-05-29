//
//  PMBeaconActivity.h
//  presentiemeter
//
//  Created by Peter Alserda on 11/05/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMBeaconDetector.h"

@interface PMBeaconActivityViewController : UITableViewController

@property (nonatomic, strong) PMBeaconDetector *beaconfinder;

@end
