//
//  ViewController.m
//  presentiemeter
//
//  Created by Peter Alserda on 14/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import <GoogleOpenSource/GoogleOpenSource.h>
#import "AFNetworking.h"

#import "PMLocationViewController.h"
#import "PMBackend.h"
#import "PMUserLogin.h"
#import "PMTableViewCell.h"
#import "PMHelper.h"
#import "PMLoginViewController.h"
#import "PMBeaconDetector.h"
#import "PMAppDelegate.h"

@interface PMLocationViewController ()

@property (nonatomic, strong) NSArray *colleagueArray;
@property (nonatomic, strong) NSArray *colleaguePresentArray;

@end

@implementation PMLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"0 Aanwezig";
    
    /* Update some styling for the tableview. */
    [self.tableView registerClass:[PMTableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 79, 0, 0);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    /* Add the sign-out button */
    [self addSignOutButton];
    
    /* Refresh the table every second in which it retrieves the colleagues locations. */
    [self makeColleagueLocationRequest];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshTable) userInfo:nil repeats:YES];
}

/* The sign-out button. */
- (void)addSignOutButton {
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logoutButton setTitleColor:[UIColor colorWithRed:0.663 green:0.663 blue:0.675 alpha:1] forState:UIControlStateHighlighted];
    [logoutButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [logoutButton sizeToFit];
    [logoutButton addTarget:self action:@selector(logoutMessage) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoutButton];
}

/* The log-out message. */
- (void)logoutMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout"
                                                    message:@"Are you sure you want to log out?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

/* Handler for signing out. */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    /* If Yes is pressed.. */
    if (buttonIndex == 1) {
        /* Destroy the Google session */
        [PMUserLogin signOut];
        
        /* Have the app delegate stop the ranging */
        PMAppDelegate *appdelegate = (PMAppDelegate *)[UIApplication sharedApplication].delegate;
        [appdelegate logOut];
    }
}

/* Retrieve the locations for all colleagues when refreshing the table. */
- (void)refreshTable {
    [self makeColleagueLocationRequest];
    [self.tableView reloadData];
}


#pragma mark - Table view delegate

/* Each cell in the tableview. */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PMTableViewCell *cell = (PMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *userinfo = [self.colleagueArray objectAtIndex:indexPath.row];
    cell.userName.text = [userinfo objectForKey:@"full_name"];
    cell.userSpecificLocation.text = @"Peperzaken";
    cell.userPhoto.email = [userinfo objectForKey:@"email"];
    cell.userLocation.textColor = [UIColor whiteColor];
    
    [cell.userPhoto load];
    
    /* Change the background-color to green & show the name of the region. */
    if ([[userinfo objectForKey:@"beacon"] isKindOfClass:[NSDictionary class]]) {
        cell.userLocation.text = [[userinfo objectForKey:@"beacon"] objectForKey:@"name"];
        cell.userLocation.backgroundColor = [UIColor colorWithRed:0.196 green:0.749 blue:0.184 alpha:1];
    }
    /* Change the background-color to orange & show the geofence location. */
    else if ([[userinfo objectForKey:@"geofence"] isKindOfClass:[NSDictionary class]]) {
        cell.userLocation.text = [[userinfo objectForKey:@"geofence"] objectForKey:@"name"];
        cell.userLocation.backgroundColor = [UIColor colorWithRed:0.953 green:0.612 blue:0.071 alpha:1];
    }
    /* Change the background-color to red and make it unavailable. */
    else {
        cell.userLocation.text = @"Unavailable";
        cell.userLocation.backgroundColor = [UIColor colorWithRed:0.867 green:0.294 blue:0.224 alpha:1];
    }
    
    /* Remove the separator under the last cell. */
    if (indexPath.row == self.colleagueArray.count - 1) {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
    }

    return cell;
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.colleagueArray count];
}

/* Request for retrieving the locations for all colleagues. */
- (void)makeColleagueLocationRequest {
    [[PMBackend sharedInstance] retrievePath:kPresentiemeterEmployeeLocationPath
                                     success:^(id json) {
                                         self.colleagueArray = json;
                                         
                                         /* Check how many people are available and update the title with this number. */
                                         NSPredicate *presentPredicateFilter = [NSPredicate predicateWithFormat:@"beacon.name!=nil AND beacon.name!='' OR geofence.name!=nil AND geofence.name!=''"];
                                         self.colleaguePresentArray = [self.colleagueArray filteredArrayUsingPredicate:presentPredicateFilter];
                                         self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"%ld Aanwezig", (long)self.colleaguePresentArray.count];
                                         
                                         /* Reload the tableview */
                                         [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                     } failure:^(NSError *error) {
                                         NSLog(@"Failure: %@", error);
                                     }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
