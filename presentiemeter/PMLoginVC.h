//
//  PMLoginVC.h
//  presentiemeter
//
//  Created by Peter Alserda on 17/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>

static NSString * const kClientId = @"710333786173-vhcthsh1ikv57m8k1419uko2uv9snaf8.apps.googleusercontent.com";

@class GPPSignInButton;

@interface PMLoginVC : UIViewController <GPPSignInDelegate>

@property(weak, nonatomic) GPPSignInButton *googlePlusSignInButton;

@end
