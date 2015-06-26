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
        [self addImageContainer];
        [self addInformationContainer];
        
        [self addUserPhoto];
        [self addUserLocation];
        [self addUsernameLabel];
        [self addUserSpecificLocation];
    }
    return self;
}

/* Adds the image container, which contains the gravatar photo. */
- (void)addImageContainer {
    self.imageContainer = [[UIView alloc] initWithFrame:CGRectMake(8, 0, 60, self.contentView.bounds.size.height)];
    self.imageContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.imageContainer];
}

/* Adds the gravatar photo */
- (void)addUserPhoto {
    self.userPhoto = [[RFGravatarImageView alloc] initWithFrame:CGRectMake(0, 5, 50, 50)];
    self.userPhoto.backgroundColor = [UIColor whiteColor];
    self.userPhoto.forceDefault = NO;
    self.userPhoto.defaultGravatar = RFDefaultGravatarMysteryMan;
    self.userPhoto.layer.masksToBounds = YES;
    self.userPhoto.layer.cornerRadius = 25;
    [self.imageContainer addSubview:self.userPhoto];
}

/* Adds the other part of the cell, anything to the right of the imageContainer */
- (void)addInformationContainer {
    self.informationContainer = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imageContainer.frame) + 6, 0, self.contentView.bounds.size.width - self.imageContainer.bounds.size.width, self.contentView.bounds.size.height)];
    self.informationContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.informationContainer];
}

/* Adds the users location (the right label) */
- (void)addUserLocation {
    self.userLocation = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90.0, 30.0)];
    self.userLocation.layer.cornerRadius = 2.5;
    self.userLocation.textAlignment = NSTextAlignmentCenter;
    self.userLocation.font = [UIFont fontWithName:@"Helvetica" size:12];
    self.userLocation.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.userLocation.clipsToBounds = YES;
    self.accessoryView = self.userLocation;
}

/* Adds the username. */
- (void)addUsernameLabel {
    self.userName = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.informationContainer.bounds.size.width - (CGRectGetMaxX(self.userLocation.bounds) + 30), 5)];
    self.userName.textColor = [UIColor blackColor];
    self.userName.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    self.userName.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.informationContainer addSubview:self.userName];
}

/* Adds the users specific location. This is the label under the username. */
- (void)addUserSpecificLocation {
    self.userSpecificLocation = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.userName.bounds)
                                                                          + 26, self.informationContainer.bounds.size.width - (CGRectGetMaxX(self.userLocation.bounds) + 30), 1)];
    self.userSpecificLocation.textColor = [UIColor colorWithRed:0.663 green:0.663 blue:0.675 alpha:1];
    self.userSpecificLocation.font = [UIFont fontWithName:@"Helvetica" size:12];
    self.userSpecificLocation.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.informationContainer addSubview:self.userSpecificLocation];
    
}

@end
