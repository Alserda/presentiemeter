//
//  PMBeaconActivity.m
//  presentiemeter
//
//  Created by Peter Alserda on 11/05/15.
//  Copyright (c) 2015 Peter Alserda. All rights reserved.
//

#import "PMBeaconActivityViewController.h"
#import "PMBeaconDetector.h"

@interface PMBeaconActivityViewController ()

@property (nonatomic, strong) PMBeaconDetector *beaconfinder;

@end

@implementation PMBeaconActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = @"Activity";
        self.beaconfinder = [PMBeaconDetector new];
        [self.beaconfinder start];
        NSLog(@"BEACON DETECTOR LOADED");
    }
    
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self.tableView selector:@selector(reloadData) userInfo:nil repeats:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.beaconfinder.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [self.beaconfinder.locations objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:8];
    return cell;
}

@end

