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

@implementation ServerViewController

@synthesize gameId, game, servers, serverCellNib, dateFormatter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.gameId = nil;
    self.game = nil;
    self.servers = nil;
    self.serverCellNib =nil;
    self.dateFormatter = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (UINib *)serverCellNib {
    if (!serverCellNib) {
        self.serverCellNib = [ServerCell nib];
    }
    return serverCellNib;
}

- (NSDateFormatter *)dateFormatter {
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    return dateFormatter;
}

- (void)refresh {
    [self loadGame];
    [super refresh];
}

- (void)loadGame {
    [SOEStatusAPI getGameStatus:gameId completion:^(PLRestful *api, id object, int status, NSError *error) {
        if (error) {
            [PRPAlertView showWithTitle:@"Error" message:[error localizedDescription] buttonTitle:@"Continue"];
            return;
        }
        self.game = [object valueForKey:@"game"];
        self.servers = [object valueForKey:@"regionServers"];        
        [self.tableView reloadData];
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadGame];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    NSDictionary *server = [self.servers objectAtIndex:indexPath.row];
    NSString *status = [server valueForKey:@"status"];
    
    cell.serverName.text = [server valueForKey:@"name"];
    cell.region.text = [server valueForKey:@"region"];
    cell.age.text = [self.dateFormatter stringFromDate:[server valueForKey:@"date"]];
    cell.status.text = status;
    
    if ([status isEqualToString:@"low"]) {
        cell.imageView.image = [UIImage imageNamed:@"low_icon"];
    } else if ([status isEqualToString:@"medium"]) {
        cell.imageView.image = [UIImage imageNamed:@"medium_icon"];
    } else if ([status isEqualToString:@"high"]) {
        cell.imageView.image = [UIImage imageNamed:@"high_icon"];
    } else if ([status isEqualToString:@"locked"]) {
        cell.imageView.image = [UIImage imageNamed:@"lock_icon"];
    } else if ([status isEqualToString:@"down"]) {
        cell.imageView.image = [UIImage imageNamed:@"down_icon"];
    }
    return cell;
}

@end
