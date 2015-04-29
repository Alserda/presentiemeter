//
//  ViewController.m
//  presentiemeter
//
//  Created by Peter Alserda on 14/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import <GoogleOpenSource/GoogleOpenSource.h>
#import "AFNetworking.h"

#import "PMLocationVC.h"
#import "PMBackend.h"
#import "PMUserLogin.h"
#import "PMTableViewCell.h"
#import "PMHelper.h"


@interface PMLocationVC () <ESTBeaconManagerDelegate, ESTUtilityManagerDelegate>

@property (nonatomic, copy)     void (^completion)(CLBeacon *);
@property (nonatomic, assign)   ESTScanType scanType;

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTUtilityManager *utilityManager;
@property (nonatomic, strong) CLBeaconRegion *region;
@property (nonatomic, strong) NSArray *beaconsArray;
@property (nonatomic, strong) NSArray *colleagueArray;
@property (nonatomic, strong) NSArray *colleaguePresentArray;
@property (nonatomic, strong) NSDictionary *googlePlusUserInfo;

@end

@implementation PMLocationVC

- (id)initWithScanType:(ESTScanType)scanType completion:(void (^)(id))completion
{
    self = [super init];
    if (self)
    {
        self.scanType = scanType;
        self.completion = [completion copy];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"0 Present";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = YES;
    
    // View to add a border under the navigationBar.
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width, 1)];
    [navBorder setBackgroundColor:[UIColor colorWithRed:0.243 green:0.243 blue:0.243 alpha:1]];
    [navBorder setOpaque:YES];
    [self.navigationController.navigationBar addSubview:navBorder];
    
    
    self.googlePlusUserInfo = [PMUserLogin authenticatedUserInfo];
    if (self.googlePlusUserInfo == nil) {
        [PMUserLogin fetchGooglePlusUserData:^(NSDictionary *googleUserInfo) {
            NSLog(@"received userinfo: %@", googleUserInfo);
            self.googlePlusUserInfo = googleUserInfo;
        }];
    }
    [self.tableView registerClass:[PMTableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    self.utilityManager = [[ESTUtilityManager alloc] init];
    self.utilityManager.delegate = self;
    [self makeColleagueLocationRequest];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    /*
     * Creates sample region object (you can additionaly pass major / minor values).
     *
     * We specify it using only the ESTIMOTE_PROXIMITY_UUID because we want to discover all
     * hardware beacons with Estimote's proximty UUID.
     */
    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                     identifier:@"EstimoteSampleRegion"];
    self.region.notifyEntryStateOnDisplay = YES;
    self.region.notifyOnEntry = YES;
    self.region.notifyOnExit = YES;
    
    /*
     * Starts looking for Estimote beacons.
     * All callbacks will be delivered to beaconManager delegate.
     */
    if (self.scanType == ESTScanTypeBeacon)
    {
        [self startRangingBeacons];
    }
    else
    {
        [self.utilityManager startEstimoteBeaconDiscoveryWithUpdateInterval:1];
    }
}

-(void)startRangingBeacons
{
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            /*
             * No need to explicitly request permission in iOS < 8, will happen automatically when starting ranging.
            */

            [self.beaconManager startMonitoringForRegion:self.region];
            [self.beaconManager startRangingBeaconsInRegion:self.region];
            [self.beaconManager requestStateForRegion:self.region];
        } else {
            /*
             * Request permission to use Location Services. (new in iOS 8)
             * We ask for "always" authorization so that the Notification Demo can benefit as well.
             * Also requires NSLocationAlwaysUsageDescription in Info.plist file.
             *
             * For more details about the new Location Services authorization model refer to:
             * https://community.estimote.com/hc/en-us/articles/203393036-Estimote-SDK-and-iOS-8-Location-Services
             */
            
            [self.beaconManager requestAlwaysAuthorization];
            
        }
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        [self.beaconManager startRangingBeaconsInRegion:self.region];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Access Denied"
                                                        message:@"You have denied access to location services. Change this in app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Not Available"
                                                        message:@"You have no access to location services."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
}

#pragma mark - ESTBeaconManager delegate

- (void)beaconManager:(id)manager didStartMonitoringForRegion:(CLBeaconRegion *)region {
    NSLog(@"didStartMonitoringForRegion");
}


- (void)beaconManager:(id)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Ranging error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [errorView show];
}

- (void)beaconManager:(id)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Monitoring error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [errorView show];
}

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    self.beaconsArray = beacons;
    NSLog(@"DidRangeBeacons:%@", self.beaconsArray);
    
    [self.tableView reloadData];
}

- (void)utilityManager:(ESTUtilityManager *)manager didDiscoverBeacons:(NSArray *)beacons
{
    self.beaconsArray = beacons;
//    NSLog(@"Array of beacons: %@", self.beaconsArray);
    
    if (beacons.count == 0) {
        NSLog(@"No beacons found");
        [self makeColleagueLocationRequest];
    }
    else {
        id beacon = [beacons objectAtIndex:0];
        ESTBluetoothBeacon *cBeacon = (ESTBluetoothBeacon *)beacon;
        
         // Used to upcase the macAddress and add colons, so they match the API's registered macAddress.
        NSMutableString *macAddress = [PMHelper formatMacAddress:cBeacon.macAddress];
        
        
//        NSLog(@"Mac Address: %@", macAddress);
    
//        UILocalNotification *notification = [UILocalNotification new];
//        notification.alertBody = @"Posted a location to the API";
//                  
//        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];

        
        [[PMBackend sharedInstance] updateUserLocation:kPresentiemeterUpdateLocationPath
                                          withLocation:macAddress
                                           forUsername:self.googlePlusUserInfo[@"full_name"]
                                              andEmail:self.googlePlusUserInfo[@"email"]
                                               success:^(id json) {
                                                   NSLog(@"POST succesful");
                                               } failure:^(NSError *error) {
                                                   NSLog(@"POST failed");
                                               }];

}

    [self makeColleagueLocationRequest];
    [self.tableView reloadData];
}

- (void)beaconManager:(ESTBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLBeaconRegion *)region {
    if(state == CLRegionStateInside) {
        NSLog(@"Currently inside region: %@", region);
    }
    else {
        NSLog(@"Not inside any region");
    }
}


- (void)beaconManager:(ESTBeaconManager *)manager didEnterRegion:(CLBeaconRegion *)region {
    NSLog(@"didEnterRegion:%@", region);
    
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = @"Enter region notification";
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)beaconManager:(ESTBeaconManager *)manager didExitRegion:(CLBeaconRegion *)region {
    NSLog(@"didExitRegion:%@", region);
    
    
    [[PMBackend sharedInstance] updateUserLocation:kPresentiemeterUpdateLocationPath
                                      withLocation: @"None"
                                       forUsername:self.googlePlusUserInfo[@"full_name"]
                                          andEmail:self.googlePlusUserInfo[@"email"]
                                           success:^(id json) {
//                                               NSLog(@"POST succesful");
                                           } failure:^(NSError *error) {
                                               NSLog(@"POST failed");
                                           }];
    
    
    
    UILocalNotification *notification = [UILocalNotification new];
    notification.alertBody = @"Exit region notification";
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    PMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
//
//    NSDictionary *userinfo = [self.colleagueArray objectAtIndex:indexPath.row];
//    cell.textLabel.text = [userinfo objectForKey:@"full_name"];
//    cell.detailTextLabel.text = [[userinfo objectForKey:@"beacon"] objectForKey:@"location_name"];
//    return cell;

    PMTableViewCell *cell = (PMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    NSDictionary *userinfo = [self.colleagueArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userName.text = [userinfo objectForKey:@"full_name"];
    cell.userLocation.text = [[userinfo objectForKey:@"beacon"] objectForKey:@"location_name"];
    cell.userPhoto.image = [UIImage imageNamed:@"PZLogo"];
    
    if ([[[userinfo objectForKey:@"beacon"] objectForKey:@"location_name"] isEqualToString:@"Unavailable"]) {
        cell.userLocation.backgroundColor = [UIColor colorWithRed:0.922 green:0.165 blue:0.216 alpha:1];
    }
    else {
        cell.userLocation.backgroundColor = [UIColor colorWithRed:0.196 green:0.749 blue:0.184 alpha:1];
    }
    cell.userLocation.textColor = [UIColor whiteColor];
    

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
                                         
                                         NSPredicate * presentPredicateFilter = [NSPredicate predicateWithFormat:@"NOT (beacon.location_name in %@)", @"Unavailable"];
                                         self.colleaguePresentArray = [self.colleagueArray filteredArrayUsingPredicate:presentPredicateFilter];
                                         self.title = [NSString stringWithFormat:@"%ld present", (long)self.colleaguePresentArray.count];
//                                         NSLog(@"The Array: %@",self.colleaguePresentArray);
                                         
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
