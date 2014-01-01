//
//  StopsViewController.m
//  UMBus
//
//  Created by Jonah Grant on 12/18/13.
//  Copyright (c) 2013 Jonah Grant. All rights reserved.
//

#import "StopsViewController.h"
#import "StopsViewControllerModel.h"
#import "StopViewController.h"
#import "Stop.h"
#import "StopCell.h"
#import "StopCellModel.h"
#import "Constants.h"

@implementation StopsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.model = [[StopsViewControllerModel alloc] init];
    
    self.navigationItem.title = kUniversityOfMichigan;
    
    [self.refreshControl addTarget:self.model action:@selector(fetchData) forControlEvents:UIControlEventValueChanged];
    
    [RACObserve(self.model, stops) subscribeNext:^(NSArray *stops) {
        if (self.refreshControl.isRefreshing)
            [self.refreshControl endRefreshing];
        
        if (stops)
            [self.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setTintColor:nil];
    [self.tabBarController.tabBar setTintColor:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.model.stops.count == 0) {
        return 1;
    }
    
    return self.model.stops.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.model.stops.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoneCell" forIndexPath:indexPath];
        
        cell.textLabel.text = kErrorNoStopsInService;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    } else {
        StopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        if (cell) {
            StopCellModel *stopCellModel = self.model.stopCellModels[indexPath.row];
            cell.model = stopCellModel;
        }
        
        return cell;
    }
    
    return nil;
}

#pragma UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.model.stops.count > 0) {
        [self performSegueWithIdentifier:UMSegueStop sender:self];
    }
}

#pragma UIStoryboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:UMSegueStop]) {
        StopViewController *controller = (StopViewController *)segue.destinationViewController;
        Stop *stop = self.model.stops[[self.tableView indexPathForSelectedRow].row];
        controller.stop = stop;
    }
}

@end