//
//  ServerViewController.m
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import "ServerViewController.h"

@implementation ServerViewController

@synthesize game, servers;

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

- (void)refresh {
    [super refresh];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSMutableArray *regionServers = [NSMutableArray array];
    for (NSDictionary *region in [self.game allValues]) {
        for (NSString *serverName in [[region allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
            NSMutableDictionary *server = [[region objectForKey:serverName] mutableCopy];
            [server setObject:serverName forKey:@"name"];
            [regionServers addObject:server];
            [server release];
        }
    }
    self.servers = regionServers;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    NSDictionary *server = [self.servers objectAtIndex:indexPath.row];
    NSString *age = [server valueForKey:@"age"];
    NSString *status = [server valueForKey:@"status"];
    NSString *name = [server valueForKey:@"name"];
    cell.textLabel.text = name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", age, status];
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
