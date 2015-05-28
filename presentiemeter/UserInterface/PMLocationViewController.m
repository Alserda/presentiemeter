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

@interface PMLocationViewController ()

@property (nonatomic, strong) NSArray *colleagueArray;
@property (nonatomic, strong) NSArray *colleaguePresentArray;

@end

@implementation PMLocationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Colleagues";

    
    // View to add a border under the navigationBar.
    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width, 1)];
    [navBorder setBackgroundColor:[UIColor colorWithRed:0.243 green:0.243 blue:0.243 alpha:1]];
    
//    [self.navigationController.navigationBar addSubview:navBorder];
    [self.tableView registerClass:[PMTableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self makeColleagueLocationRequest];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshTable) userInfo:nil repeats:YES];
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
        cell.userLocation.backgroundColor = [UIColor colorWithRed:0.922 green:0.165 blue:0.216 alpha:1];
    }
    cell.userPhoto.email = [userinfo objectForKey:@"email"];
    
    [cell.userPhoto load];

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
//                                         NSLog(@"Obtained JSON: %@", json);
//                                         NSLog(@"Json count: %i", [json count]);

                                         self.colleagueArray = json;
                                         
//                                         NSLog(@"The Array: %@",self.colleagueArray);
                                         
//                                         NSPredicate * presentPredicateFilter = [NSPredicate predicateWithFormat:@"NOT (beacon.name in %@)", @"Vergaderbar"];
                                         NSPredicate *presentPredicateFilter = [NSPredicate predicateWithFormat:@"beacon.name!=nil AND beacon.name!='' OR geofence.name!=nil AND geofence.name!=''"];
                                         self.colleaguePresentArray = [self.colleagueArray filteredArrayUsingPredicate:presentPredicateFilter];
                                         self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"%ld present", (long)self.colleaguePresentArray.count];
//                                         NSLog(@"Formatted array: %@", self.colleaguePresentArray);
                                         
                                         
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
