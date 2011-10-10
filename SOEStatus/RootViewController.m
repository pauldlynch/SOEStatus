//
//  RootViewController.m
//  SOEStatus
//
//  Created by Paul Lynch on 02/09/2011.
//  Copyright 2011 P & L Systems. All rights reserved.
//

#import "RootViewController.h"
#import "SOEStatusAPI.h"
#import "PRPAlertView.h"
#import "MoveArray.h"
#import "ServerViewController.h"

@implementation RootViewController

@synthesize statuses, rows;

- (NSDictionary *)rowForKey:(NSString *)key {
    for (NSDictionary *game in self.rows) {
        if ([key isEqualToString:[game valueForKey:@"key"]]) {
            return game;
        }
    }
    return nil;
}

- (void)refresh {
    [super refresh];
    
    [SOEStatusAPI getStatuses:^(PLRestful *api, id object, int status, NSError *error){
        if (error) {
            NSString *message = [NSString stringWithFormat:@"%@", [error localizedDescription]];
            [PRPAlertView showWithTitle:@"API Error" message:message buttonTitle:@"Continue"];
        } else {
            self.statuses = object;
            // remove dropped games
            for (NSDictionary *game in self.rows) {
                if (![self.statuses objectForKey:[game valueForKey:@"key"]]) [self.rows removeObject:game];
            }
            // add missing games
            for (NSString *key in [self.statuses allKeys]) {
                if (![self rowForKey:key]) [self.rows addObject:[NSDictionary dictionaryWithObject:key forKey:@"key"]];
            }
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *filePath = [documentsPath stringByAppendingPathComponent:@"rows.plist"];
            [self.rows writeToFile:filePath atomically:YES];

            [self.tableView reloadData];
        }
    }];
}

- (void)editing {
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
    if (self.tableView.isEditing) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editing)];
        self.navigationItem.rightBarButtonItem = doneButton;
        [doneButton release];
    } else {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editing)];
        self.navigationItem.rightBarButtonItem = editButton;
        [editButton release];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"rows.plist"];
        [self.rows writeToFile:filePath atomically:YES];
    }
}

- (void)actions {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.soe.com/status"]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Games";
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editing)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
    
    UIBarButtonItem *actionsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actions)];
    self.navigationItem.leftBarButtonItem = actionsButton;
    [actionsButton release];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"rows.plist"];
    self.rows = [NSMutableArray arrayWithContentsOfFile:filePath];
    if (!rows) self.rows = [NSMutableArray array];
    for (NSDictionary *game in [SOEStatusAPI games]) {
        NSString *key = [game valueForKey:@"key"];
        if (![self rowForKey:key]) {
            [rows addObject:game];
        }
    }
    
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.rows count];
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
    NSDictionary *game = [self.rows objectAtIndex:indexPath.row];
    NSString *key = [game valueForKey:@"key"];
    NSString *value = [game valueForKey:@"name"];
    if (!value) value = key;
    cell.textLabel.text = value;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [self.rows removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.rows moveObjectFromIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServerViewController *detailViewController = [[ServerViewController alloc] initWithNibName:@"ServerViewController" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    detailViewController.gameId = [[self.rows objectAtIndex:indexPath.row] valueForKey:@"key"];
    detailViewController.title = [[self.rows objectAtIndex:indexPath.row] valueForKey:@"name"];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    self.statuses = nil;
    [super dealloc];
}

@end
