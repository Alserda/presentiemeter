//
//  PMTableViewCell.h
//  presentiemeter
//
//  Created by Peter Alserda on 20/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFGravatarImageView.h"

@interface PMTableViewCell : UITableViewCell

@property (strong, nonatomic) UIView *imageContainer;
@property (strong, nonatomic) RFGravatarImageView *userPhoto;
@property (strong, nonatomic) UIView *informationContainer;
@property (strong, nonatomic) UILabel *userName;
@property (strong, nonatomic) UILabel *userLocation;
@property (strong, nonatomic) UILabel *userSpecificLocation;


@end
