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


@interface PMLocationVC () <ESTBeaconManagerDelegate, ESTUtilityManagerDelegate>

@property (nonatomic, copy)     void (^completion)(CLBeacon *);
@property (nonatomic, assign)   ESTScanType scanType;

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTUtilityManager *utilityManager;
@property (nonatomic, strong) CLBeaconRegion *region;
@property (nonatomic, strong) NSArray *beaconsArray;
@property (nonatomic, strong) NSArray *colleagueArray;
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
    
    [PMUserLogin fetchGooglePlusUserData:^(NSDictionary *googleUserInfo) {
        NSLog(@"received userinfo: %@", googleUserInfo);
        self.googlePlusUserInfo = googleUserInfo;
    }];
    [self.tableView registerClass:[PMTableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    
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
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kPresentiemeterBaseURL]];
        NSDictionary *parameters = @{
                                     @"full_name": self.googlePlusUserInfo[@"full_name"],
                                     @"email": self.googlePlusUserInfo[@"email"],
                                     @"address": @"None"};
        
        [manager POST:kPresentiemeterUpdateLocationPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"No beacons found. Obtained JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    else {
        id beacon = [beacons objectAtIndex:0];
        ESTBluetoothBeacon *cBeacon = (ESTBluetoothBeacon *)beacon;
        
         // Used to upcase the macAddress and add colons, so they match the API's registered macAddress.
        NSMutableString *macAddress = [NSMutableString stringWithString:[cBeacon.macAddress uppercaseString]];
        [macAddress insertString: @":" atIndex: 2];
        [macAddress insertString: @":" atIndex: 5];
        [macAddress insertString: @":" atIndex: 8];
        [macAddress insertString: @":" atIndex: 11];
        [macAddress insertString: @":" atIndex: 14];
        
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kPresentiemeterBaseURL]];
        
        NSDictionary *parameters = @{
                                     @"full_name": self.googlePlusUserInfo[@"full_name"],
                                     @"email": self.googlePlusUserInfo[@"email"],
                                     @"address": macAddress};
        
        [manager POST:kPresentiemeterUpdateLocationPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
}

    
    [self.tableView reloadData];
}

- (void)beaconManager:(id)manager didEnterRegion:(CLBeaconRegion *)region {
    NSLog(@"didEnterRegion:%@", region);
}

- (void)beaconManager:(id)manager didExitRegion:(CLBeaconRegion *)region {
    NSLog(@"didExitRegion:%@", region);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];

    NSDictionary *userinfo = [self.colleagueArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [userinfo objectForKey:@"full_name"];
    cell.detailTextLabel.text = [[userinfo objectForKey:@"beacon"] objectForKey:@"location_name"];
    
//    /*
//     * Fill the table with beacon data.
//     */
//    
//    id beacon = [self.beaconsArray objectAtIndex:indexPath.row];
//    
//    if ([beacon isKindOfClass:[CLBeacon class]])
//    {
//        CLBeacon *cBeacon = (CLBeacon *)beacon;
//        
//        cell.textLabel.text = [NSString stringWithFormat:@"Major: %@, Minor: %@", cBeacon.major, cBeacon.minor];
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %.2f", cBeacon.accuracy];
//    }
//    else if([beacon isKindOfClass:[ESTBluetoothBeacon class]])
//    {
//        ESTBluetoothBeacon *cBeacon = (ESTBluetoothBeacon *)beacon;
//        
//        // Used to upcase the macAddress and add colons, so they match the API's registered macAddress.
//        NSMutableString *macAddress = [NSMutableString stringWithString:[cBeacon.macAddress uppercaseString]];
//        [macAddress insertString: @":" atIndex: 2];
//        [macAddress insertString: @":" atIndex: 5];
//        [macAddress insertString: @":" atIndex: 8];
//        [macAddress insertString: @":" atIndex: 11];
//        [macAddress insertString: @":" atIndex: 14];
//        
//        cell.textLabel.text = [NSString stringWithFormat:@"Mac Address: %@", macAddress];
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI: %zd", cBeacon.rssi];
//        
////        NSLog(@"Mac Address: %@", macAddress);
//    }
    return cell;
//    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CLBeacon *selectedBeacon = [self.beaconsArray objectAtIndex:indexPath.row];
    
//    self.completion(selectedBeacon);
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
                                         
                                         NSLog(@"The Array: %@",self.colleagueArray);
                                         
                                         [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                     } failure:^(NSError *error) {
                                         NSLog(@"Failure: %@", error);
                                     }];
//    NSURL *url = [NSURL URLWithString:@"http://presentiemeter.peperzaken.nl:8000/api/employees/"];
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    //AFNetworking asynchronous url request
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    operation.responseSerializer = [AFJSONResponseSerializer serializer];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        self.colleagueArray = responseObject;
//        
//        NSLog(@"The Array: %@",self.colleagueArray);
//        
//        [self.tableView reloadData];
//        
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        NSLog(@"Request Failed: %@, %@", error, error.userInfo);
//        
//    }];
//    
//    [operation start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
