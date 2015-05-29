//
//  PMLoginVC.m
//  presentiemeter
//
//  Created by Peter Alserda on 17/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import "PMLoginViewController.h"
#import "PMLocationViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>

@implementation PMLoginViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    
    signIn.clientID = kClientId;
    
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    signIn.scopes = @[ @"profile" ];
    signIn.delegate = self;

    UIImageView *peperzakenLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PZLogo"]];
    peperzakenLogo.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2 - 100);
    
    UIImageView *peperzakenText = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PZText"]];
    peperzakenText.frame = CGRectMake(0, 0, 240, 42);
    peperzakenText.center = CGPointMake(self.view.frame.size.width / 2, peperzakenLogo.center.y + 60);
    NSLog(@"%@", NSStringFromCGSize(peperzakenLogo.image.size));
    
    UILabel *productName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(peperzakenText.frame), 50)];
    productName.center = CGPointMake(self.view.frame.size.width / 2, peperzakenText.center.y + 40);
    productName.text = @"Presentie";
    productName.textColor = [UIColor whiteColor];
    productName.textAlignment = UIBaselineAdjustmentAlignCenters;
    productName.numberOfLines = 1;
    productName.font = [UIFont fontWithName:@"Helvetica" size:20];

    /** This is a customized Google+ button, as used in Danny's design. But the linking does not work properly. */
//    UIButton *googlePlusButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    googlePlusButton.frame = CGRectMake(0, 0, 244, 40);
//    [googlePlusButton setTitle:@"Login with Google+" forState:UIControlStateNormal];
//    [googlePlusButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
//    [googlePlusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [googlePlusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//    [googlePlusButton setBackgroundImage:[UIImage imageNamed:@"gpbuttonactive"] forState:UIControlStateNormal];
//    [googlePlusButton setBackgroundImage:[UIImage imageNamed:@"gpbuttonpressed"] forState:UIControlStateHighlighted];
//    [googlePlusButton addTarget:self action:@selector(signInGoogle) forControlEvents:UIControlEventTouchUpInside];
//    googlePlusButton.center = CGPointMake(self.view.frame.size.width / 2, productName.center.y + 75);
//    [self.view addSubview:googlePlusButton];
    
    _googlePlusSignInButton = [GPPSignInButton buttonWithType:UIButtonTypeCustom];
    _googlePlusSignInButton.style = kGPPSignInButtonStyleWide;
    _googlePlusSignInButton.colorScheme = kGPPSignInButtonColorSchemeDark;
    _googlePlusSignInButton.center = CGPointMake(self.view.frame.size.width / 2, productName.center.y + 75);
    
    [self.view addSubview:peperzakenLogo];
    [self.view addSubview:peperzakenText];
    [self.view addSubview:productName];

    [self.view addSubview:_googlePlusSignInButton];

}

- (void)paddingTextField:(UITextField *)textField {
    UIView*leftPadding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 0)];
    textField.leftView = leftPadding;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        NSLog(@"Error bij finishedWithAuth");
    } else {
        [self refreshInterfaceBasedOnSignIn];
    }
}

-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        if ([self.delegate respondsToSelector:@selector(didLogin)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate performSelector:@selector(didLogin)];
            });
        }
    } else {
        self.googlePlusSignInButton.hidden = NO;
        NSLog(@"Google button hidden = NO");
        // Perform other actions here
    }
}

@end
