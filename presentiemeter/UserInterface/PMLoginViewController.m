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
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    
    signIn.clientID = kClientId;
    
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    signIn.scopes = @[ @"profile" ];
    signIn.delegate = self;
    
    
    [self addInformationContainer];
    [self addSignInContainer];
    [self addLogo];
    [self addSignInButton];
}

- (void)addInformationContainer {
    self.informationContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 115)];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"loginbackground"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.informationContainer.backgroundColor = [UIColor colorWithPatternImage:image];
    
    [self.view addSubview:self.informationContainer];
}

- (void)addSignInContainer {
    self.signInContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.informationContainer.bounds), self.view.frame.size.width, 115)];
    self.signInContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.signInContainer];
}

- (void)addLogo {
    UIImageView *peperzakenLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"peperzaken"]];
    peperzakenLogo.frame = CGRectMake(0, 0, 277, 67);
    peperzakenLogo.center = CGPointMake(self.informationContainer.frame.size.width / 2, self.informationContainer.frame.size.height / 2);
    
    [self.informationContainer addSubview:peperzakenLogo];
}

- (void)addSignInButton {
    _googlePlusSignInButton = [GPPSignInButton buttonWithType:UIButtonTypeCustom];
    _googlePlusSignInButton.style = kGPPSignInButtonStyleWide;
    _googlePlusSignInButton.colorScheme = kGPPSignInButtonColorSchemeDark;
    _googlePlusSignInButton.center = CGPointMake(self.signInContainer.frame.size.width / 2, self.signInContainer.frame.size.height / 2);
    
    [self.signInContainer addSubview:_googlePlusSignInButton];
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
