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

- (void)addImageContainer {
    self.imageContainer = [[UIView alloc] initWithFrame:CGRectMake(8, 0, 60, self.contentView.bounds.size.height)];
//    self.imageContainer.backgroundColor = [UIColor blueColor];
    self.imageContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.imageContainer];
}

- (void)addUserPhoto {
    self.userPhoto = [[RFGravatarImageView alloc] initWithFrame:CGRectMake(0, 5, 50, 50)];
    self.userPhoto.backgroundColor = [UIColor whiteColor];
    self.userPhoto.forceDefault = NO;
    self.userPhoto.defaultGravatar = RFDefaultGravatarMysteryMan;
    self.userPhoto.layer.masksToBounds = YES;
//    self.userPhoto.backgroundColor = [UIColor blueColor];
    self.userPhoto.layer.cornerRadius = 25;
    [self.imageContainer addSubview:self.userPhoto];
}

- (void)addInformationContainer {
    self.informationContainer = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.imageContainer.frame) + 6, 0, self.contentView.bounds.size.width - self.imageContainer.bounds.size.width, self.contentView.bounds.size.height)];
    self.informationContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.informationContainer.backgroundColor = [UIColor redColor];
    [self addSubview:self.informationContainer];
}

- (void)addUserLocation {
    self.userLocation = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90.0, 30.0)];
    self.userLocation.layer.cornerRadius = 2.5;
    self.userLocation.textAlignment = NSTextAlignmentCenter;
    self.userLocation.font = [UIFont fontWithName:@"Helvetica" size:12];
    self.userLocation.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.userLocation.clipsToBounds = YES;
//    [self.informationContainer addSubview:self.userLocation];
    self.accessoryView = self.userLocation;
}

- (void)addUsernameLabel {
    self.userName = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.informationContainer.bounds.size.width - (CGRectGetMaxX(self.userLocation.bounds) + 30), 5)];
    self.userName.textColor = [UIColor blackColor];
//    self.userName.backgroundColor = [UIColor whiteColor];
    self.userName.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    self.userName.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.informationContainer addSubview:self.userName];
}

- (void)addUserSpecificLocation {
    self.userSpecificLocation = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.userName.bounds)
                                                                          + 26, self.informationContainer.bounds.size.width - (CGRectGetMaxX(self.userLocation.bounds) + 30), 1)];
    self.userSpecificLocation.textColor = [UIColor colorWithRed:0.663 green:0.663 blue:0.675 alpha:1];
//    self.userSpecificLocation.backgroundColor = [UIColor brownColor];
    self.userSpecificLocation.font = [UIFont fontWithName:@"Helvetica" size:12];
    self.userSpecificLocation.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.informationContainer addSubview:self.userSpecificLocation];
    
}



@end
