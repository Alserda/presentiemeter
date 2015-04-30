//
//  PMTableViewCell.m
//  presentiemeter
//
//  Created by Peter Alserda on 20/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import "PMTableViewCell.h"

@implementation PMTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1];
        [self addUserPhoto];
        [self addUserLocation];
        [self addUsenameLabel];
    }
    return self;
}


- (void)addUserPhoto {
    self.userPhoto = [[RFGravatarImageView alloc] initWithFrame:CGRectMake(16, 5, 40, 40)];
    self.userPhoto.backgroundColor = [UIColor whiteColor];
    self.userPhoto.forceDefault = NO;
    self.userPhoto.defaultGravatar = RFDefaultGravatarMysteryMan;
    self.userPhoto.layer.masksToBounds = YES;
    self.userPhoto.layer.cornerRadius = 20;
    [self addSubview:self.userPhoto];

}



- (void)addUserLocation {
    self.userLocation = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 90.0, 30.0)];
    self.userLocation.layer.cornerRadius = 2.5;
    self.userLocation.textAlignment = NSTextAlignmentCenter;
    self.userLocation.font = [UIFont fontWithName:@"Helvetica" size:12];
    self.userLocation.clipsToBounds = YES;
    self.accessoryView = self.userLocation;
}

- (void)addUsenameLabel {
    self.userName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.userPhoto.frame) + 11, 0, self.contentView.bounds.size.width - (self.userPhoto.bounds.size.width + self.userLocation.bounds.size.width) - 43, self.contentView.bounds.size.height)];
    self.userName.textColor = [UIColor whiteColor];
    self.userName.font = [UIFont fontWithName:@"Helvetica" size:14];
    self.userName.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.userName];
}

@end
