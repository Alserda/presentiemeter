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
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self addUserPhoto];
        [self addUsenameLabel];
        [self addUserLocation];
    }
    return self;
}


- (void)addUserPhoto {

//    self.imageView.frame = CGRectMake(16, 0, 0, self.contentView.bounds.size.height);
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.backgroundColor = [UIColor redColor];
}

- (void)addUsenameLabel {
    self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame) + 12, 0, 100, self.contentView.bounds.size.height);
    self.textLabel.backgroundColor = [UIColor blueColor];
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)addUserLocation {
//    self.detailTextLabel.frame = CGRectMake(kSideSpacing, 25, 5, self.contentView.bounds.size.height);
//    self.detailTextLabel.frame = CGRectMake(0, 0, 300, 300);
//    self.detailTextLabel.backgroundColor = [UIColor brownColor];
//    NSLog(@"%@", NSStringFromCGSize(self.detailTextLabel.frame.size));
    self.userLocation = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 120.0, 40.0)];
    self.userLocation.layer.cornerRadius = 5.0;
    self.userLocation.textAlignment = NSTextAlignmentCenter;
    self.userLocation.clipsToBounds = YES;
    self.userLocation.backgroundColor = [UIColor brownColor];
    
    self.accessoryView = self.userLocation;
    
}
@end
