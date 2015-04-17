//
//  ViewController.m
//  presentiemeter
//
//  Created by Peter Alserda on 14/04/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import "PMLocationVC.h"
#import "AFNetworking.h"
#import "PMBackend.h"
#import <GoogleOpenSource/GoogleOpenSource.h>

@interface PMLocationVC () <ESTBeaconManagerDelegate, ESTUtilityManagerDelegate>

@property (nonatomic, copy)     void (^completion)(CLBeacon *);
@property (nonatomic, assign)   ESTScanType scanType;

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) ESTUtilityManager *utilityManager;
@property (nonatomic, strong) CLBeaconRegion *region;
@property (nonatomic, strong) NSArray *beaconsArray;

@end

@interface PMTableViewCell : UITableViewCell

@end

@implementation PMTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}
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
    
    [self.tableView registerClass:[PMTableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    self.utilityManager = [[ESTUtilityManager alloc] init];
    self.utilityManager.delegate = self;
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

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
                                     @"full_name": @"Peter Alserda",
                                     @"email": @"p.alserda@peperzaken.nl",
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
        
        NSMutableString *string1 = [NSMutableString stringWithString:[cBeacon.macAddress uppercaseString]];
        
        [string1 insertString: @":" atIndex: 2];
        [string1 insertString: @":" atIndex: 5];
        [string1 insertString: @":" atIndex: 8];
        [string1 insertString: @":" atIndex: 11];
        [string1 insertString: @":" atIndex: 14];
        
        NSLog(@"Mac Address: %@", string1);
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kPresentiemeterBaseURL]];
        
        // 1. Create a |GTLServicePlus| instance to send a request to Google+.
        GTLServicePlus* plusService = [[GTLServicePlus alloc] init] ;
        plusService.retryEnabled = YES;
        
        // 2. Set a valid |GTMOAuth2Authentication| object as the authorizer.
        [plusService setAuthorizer:[GPPSignIn sharedInstance].authentication];
        
        
        GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
        
        // *4. Use the "v1" version of the Google+ API.*
        plusService.apiVersion = @"v1";
        
        [plusService executeQuery:query
                completionHandler:^(GTLServiceTicket *ticket,
                                    GTLPlusPerson *person,
                                    NSError *error) {
                    if (error) {
                        
                        
                        
                        //Handle Error
                        
                    } else
                    {
                        
                        
                        NSLog(@"Email= %@",[GPPSignIn sharedInstance].authentication.userEmail);
                        NSLog(@"GoogleID=%@",person.identifier);
                        NSLog(@"User Name=%@",[person.name.givenName stringByAppendingFormat:@" %@",person.name.familyName]);
                        NSLog(@"Gender=%@",person.gender);
                        
                    }
                }];
    
        
        
        NSDictionary *parameters = @{
                                     @"full_name": @"Peter Alserda",
                                     @"email": @"p.alserda@peperzaken.nl",
                                     @"address": string1};
        
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
    
    /*
     * Fill the table with beacon data.
     */
    
    id beacon = [self.beaconsArray objectAtIndex:indexPath.row];
    
    if ([beacon isKindOfClass:[CLBeacon class]])
    {
        CLBeacon *cBeacon = (CLBeacon *)beacon;
        
        cell.textLabel.text = [NSString stringWithFormat:@"Major: %@, Minor: %@", cBeacon.major, cBeacon.minor];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %.2f", cBeacon.accuracy];
    }
    else if([beacon isKindOfClass:[ESTBluetoothBeacon class]])
    {
        ESTBluetoothBeacon *cBeacon = (ESTBluetoothBeacon *)beacon;
        
        NSMutableString *string1 = [NSMutableString stringWithString:[cBeacon.macAddress uppercaseString]];
        
        [string1 insertString: @":" atIndex: 2];
        [string1 insertString: @":" atIndex: 5];
        [string1 insertString: @":" atIndex: 8];
        [string1 insertString: @":" atIndex: 11];
        [string1 insertString: @":" atIndex: 14];
        
        cell.textLabel.text = [NSString stringWithFormat:@"Mac Address: %@", string1];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI: %zd", cBeacon.rssi];
        
//        NSLog(@"Mac Address: %@", string1);
    }
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
    CLBeacon *selectedBeacon = [self.beaconsArray objectAtIndex:indexPath.row];
    
    self.completion(selectedBeacon);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.beaconsArray count];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
