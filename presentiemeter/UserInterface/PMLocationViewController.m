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
@property (nonatomic, strong) PMBeaconDetector *beaconfinder;
@property (nonatomic, strong) CBCentralManager *bluetoothManager;

@end

@implementation PMLocationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"0 Aanwezig";
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logoutButton setTitleColor:[UIColor colorWithRed:0.663 green:0.663 blue:0.675 alpha:1] forState:UIControlStateHighlighted];
    [logoutButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [logoutButton sizeToFit];
    [logoutButton addTarget:self action:@selector(testLogout) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoutButton];    
    
    
    [self.tableView registerClass:[PMTableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.902 green:0.902 blue:0.902 alpha:1];
//    self.tableView.layoutMargins = UIEdgeInsetsMake(-20, -20, -20, -20);
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 79, 0, 0);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self detectBluetooth];
    
    [self makeColleagueLocationRequest];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshTable) userInfo:nil repeats:YES];
}

- (void)testLogout {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout"
                                                    message:@"Weet je zeker dat je wilt uitloggen?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) { // Set buttonIndex == 0 to handel "Ok"/"Yes" button response
        [PMUserLogin signOut];
        // Have the app delegate stop the ranging
        PMAppDelegate *appdelegate = (PMAppDelegate *)[UIApplication sharedApplication].delegate;
        [appdelegate logOut];
    }
}

- (void)refreshTable {
    [self makeColleagueLocationRequest];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    PMTableViewCell *cell = (PMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    NSDictionary *userinfo = [self.colleagueArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userName.text = [userinfo objectForKey:@"full_name"];
    cell.userSpecificLocation.text = @"Peperzaken";
    if ([[userinfo objectForKey:@"beacon"] isKindOfClass:[NSDictionary class]]) {
        cell.userLocation.text = [[userinfo objectForKey:@"beacon"] objectForKey:@"name"];
        cell.userLocation.backgroundColor = [UIColor colorWithRed:0.196 green:0.749 blue:0.184 alpha:1];
    }
    else if ([[userinfo objectForKey:@"geofence"] isKindOfClass:[NSDictionary class]]) {
        cell.userLocation.text = [[userinfo objectForKey:@"geofence"] objectForKey:@"name"];
        cell.userLocation.backgroundColor = [UIColor colorWithRed:0.953 green:0.612 blue:0.071 alpha:1];
    }
    else {
        cell.userLocation.text = @"Unavailable";
        cell.userLocation.backgroundColor = [UIColor colorWithRed:0.867 green:0.294 blue:0.224 alpha:1];
    }
    cell.userPhoto.email = [userinfo objectForKey:@"email"];
    
    [cell.userPhoto load];

    cell.userLocation.textColor = [UIColor whiteColor];
    
    if (indexPath.row == self.colleagueArray.count-1) {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
    }
    

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.colleagueArray count];
}

- (void)makeColleagueLocationRequest {
    
    [[PMBackend sharedInstance] retrievePath:kPresentiemeterEmployeeLocationPath
                                     success:^(id json) {
                                         self.colleagueArray = json;
                                         
                                         NSPredicate *presentPredicateFilter = [NSPredicate predicateWithFormat:@"beacon.name!=nil AND beacon.name!='' OR geofence.name!=nil AND geofence.name!=''"];
                                         self.colleaguePresentArray = [self.colleagueArray filteredArrayUsingPredicate:presentPredicateFilter];
                                         self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"%ld Aanwezig", (long)self.colleaguePresentArray.count];

                                         [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                     } failure:^(NSError *error) {
                                         NSLog(@"Failure: %@", error);
                                     }];
}

- (void)detectBluetooth
{
    if(!self.bluetoothManager)
    {
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                     queue:nil
                                                                   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                                                                       forKey:CBCentralManagerOptionShowPowerAlertKey]];
    }
    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *stateString = nil;
    switch(self.bluetoothManager.state)
    {
        case CBCentralManagerStateResetting:
            stateString = @"The connection with the system service was momentarily lost, update imminent.";
            break;
        case CBCentralManagerStateUnsupported:
            stateString = @"The platform doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            stateString = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            stateString = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            stateString = @"Bluetooth is currently powered on and available to use.";
            break;
        case CBCentralManagerStateUnknown:
            stateString = @"Bluetooth state is unknown";
            break;
            
        default: stateString = @"State unknown, update imminent."; break;
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth state"
                                                    message:stateString
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    
    [alert show];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
