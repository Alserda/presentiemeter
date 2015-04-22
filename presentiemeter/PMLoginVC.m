//
//  PMLoginVC.m
//  presentiemeter
//
//  Created by Peter Alserda on 17/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import "PMLoginVC.h"
#import "PMLocationVC.h"
#import <GoogleOpenSource/GoogleOpenSource.h>

@implementation PMLoginVC

- (void) viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    
    signIn.clientID = kClientId;
    
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    signIn.scopes = @[ @"profile" ];
    
    
    signIn.delegate = self;
    
    [self setGooglePlusButtons];

//    [[GPPSignIn sharedInstance] trySilentAuthentication];
}

- (void) viewWillAppear:(BOOL)animated {
    
}

- (void) finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
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
//        [self performSelectorOnMainThread:@selector(displayViewController) withObject:nil waitUntilDone:YES];
        if ([self.delegate respondsToSelector:@selector(didLogin)]) {
            [self.delegate performSelector:@selector(didLogin)];
        }
    } else {
        self.googlePlusSignInButton.hidden = NO;
        NSLog(@"Google button hidden = NO");
        // Perform other actions here
    }
}

-(void) displayViewController {
    PMLocationVC *vc = [[PMLocationVC alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navController animated:YES completion:nil];
}

-(void) setGooglePlusButtons {
    
    _googlePlusSignInButton = [GPPSignInButton buttonWithType:UIButtonTypeCustom];
    _googlePlusSignInButton.backgroundColor = [UIColor blueColor];
    
//    UIImage *backgroundButtonImage = [UIImage imageNamed:@"bt_search_cancel.png"];
    
//    _googlePlusSignInButton.frame = CGRectMake(0,
//                                               0,
//                                               backgroundButtonImage.size.width,
//                                               backgroundButtonImage.size.height);
    
//    _googlePlusSignInButton.center = CGPointMake(self.view.frame.size.height, self.view.frame.size.width);
    [_googlePlusSignInButton setCenter:self.view.center];
    _googlePlusSignInButton.backgroundColor = [UIColor whiteColor];
    
    _googlePlusSignInButton.titleLabel.textColor = [UIColor whiteColor];
    _googlePlusSignInButton.titleLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    _googlePlusSignInButton.titleLabel.numberOfLines = 2;
    
    _googlePlusSignInButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    _googlePlusSignInButton.titleLabel.shadowOffset = CGSizeMake(0.0f,
                                                                 -1.0f);
    
    [_googlePlusSignInButton setTitle:NSLocalizedString(@"UI_BUTTONS_LOGIN", @"")
                             forState:UIControlStateNormal];
    
    //    [_googlePlusSignInButton setBackgroundImage:backgroundButtonImage
    //                                       forState:UIControlStateNormal];
    
    [_googlePlusSignInButton addTarget:self action:@selector(signInGoogle) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_googlePlusSignInButton];
}

- (void)signInGoogle {
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.delegate = self;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = kClientId;
    signIn.scopes = [NSArray arrayWithObjects:kGTLAuthScopePlusLogin,nil];
    signIn.actions = [NSArray arrayWithObjects:@"http://schemas.google.com/ListenActivity",nil];
//    [signIn authenticate];
}

@end
