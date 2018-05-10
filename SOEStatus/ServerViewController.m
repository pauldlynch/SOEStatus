//
//  ServerViewController.m
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import "ServerViewController.h"
#import "SOEStatusAPI.h"
#import "PRPAlertView.h"
#import "ServerCell.h"
#import "ChartController.h"
#import "SOEGame.h"
#import "SOEServer.h"
#import "WatchServer.h"
#import "SOEStatusAppDelegate.h"

@implementation ServerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (UINib *)serverCellNib {
    if (!_serverCellNib) {
        self.serverCellNib = [ServerCell nib];
    }
    return _serverCellNib;
}

- (void)refresh {
    [self loadGame];
}

- (void)loadGame {
    [SOEStatusAPI getGameStatus:self.gameId completion:^(PLRestful *api, id object, NSInteger status, NSError *error) {
        if (error) {
            [PRPAlertView showWithTitle:@"Error" message:[error localizedDescription] buttonTitle:@"Continue"];
            [self.refreshControl endRefreshing];
        } else {
            self.game = [SOEGame gameForKey:self.gameId];
            self.servers = self.game.servers;
            
            CGFloat width = self.preferredContentSize.width;
            if (width == 0) width = 320.0;
            CGFloat height = 44.0 * [self.servers count];
            CGFloat maxHeight = self.tableView.superview.frame.size.height - self.tableView.frame.origin.y;
            maxHeight = [UIScreen mainScreen].bounds.size.height - self.navigationController.navigationBar.bounds.size.height - 100.0f;
            if (height > maxHeight) height = maxHeight;

            self.preferredContentSize = CGSizeMake(width, height);
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            
            [[WatchServer sharedInstance] notify];
        }
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadGame];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.servers count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    ServerCell *cell = [ServerCell cellForTableView:tableView fromNib:self.serverCellNib];
    
    // Configure the cell.
    SOEServer *server = [self.servers objectAtIndex:indexPath.row];
    cell.server = server;
    cell.vcForAlerts = self;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChartController *chartController = [[ChartController alloc] initWithNibName:@"ChartController" bundle:nil];
    SOEServer *server = [self.servers objectAtIndex:indexPath.row];
    chartController.gameCode = server.game;
    chartController.server = server.name;
    
    SOEStatusAppDelegate *appDelegate = (SOEStatusAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (appDelegate.splitViewController) {
        [appDelegate.splitViewController showDetailViewController:chartController sender:self];
    } else {
        [self.navigationController pushViewController:chartController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //SOEServer *server = [self.servers objectAtIndex:indexPath.row];
}

@end
