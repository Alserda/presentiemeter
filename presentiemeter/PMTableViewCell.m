//
//  PMTableViewCell.m
//  presentiemeter
//
//  Created by Peter Alserda on 20/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import "PMTableViewCell.h"

static const CGFloat kSideSpacing = 16.0;

@implementation PMTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
//        [self addUserPhoto];
//        [self addUsenameLabel];
    }
    return self;
}


- (void)addUserPhoto {

    self.userPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(16, 0, 50, self.contentView.bounds.size.height)];
    self.userPhoto.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.userPhoto.backgroundColor = [UIColor redColor];
    [self addSubview:self.userPhoto];
}

- (void)addUsenameLabel {
    self.userName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.userPhoto.frame) + 12, 0, 100, self.contentView.bounds.size.height)];
    self.userName.backgroundColor = [UIColor blackColor];
    self.userName.textColor = [UIColor whiteColor];
    self.userName.font = [UIFont fontWithName:@"Helvetica" size:17];
    [self addSubview:self.userName];
        self.userName.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)addUserLocation {
    self.userLocation = [[UILabel alloc] initWithFrame:CGRectMake(kSideSpacing, 25, self.frame.size.width / 2, 10)];
}
@end
