//
//  PMLoginVC.h
//  presentiemeter
//
//  Created by Peter Alserda on 17/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>

@protocol PMLoginViewControllerDelegate <NSObject>

/** Called on the delegate when user login was successfull */
- (void)didLogin;

@end

static NSString * const kClientId = @"710333786173-t904e7mn0u7dqgv53lh4cqbpgo8nfcpe.apps.googleusercontent.com";

@class GPPSignInButton;

@interface PMLoginViewController : UIViewController <GPPSignInDelegate>

/** Delegate handling the login success situation */
@property (nonatomic, weak) id<PMLoginViewControllerDelegate> delegate;

@property(strong, nonatomic) GPPSignInButton *googlePlusSignInButton;

@end
