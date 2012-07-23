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
#import "PLActionSheet.h"
#import <Twitter/Twitter.h>

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
            NSLog(@"API Error: %@", error);
            NSString *message = [NSString stringWithFormat:@"%@", [error localizedDescription]];
            [PRPAlertView showWithTitle:@"API Error" message:message buttonTitle:@"Continue"];
            //return;
        }
        self.statuses = object;
        // remove dropped games
        NSMutableArray *newRows = [NSMutableArray array];
        for (NSDictionary *game in self.rows) {
            if ([self.statuses objectForKey:[game valueForKey:@"key"]])
                [newRows addObject:game];
        }
        self.rows = newRows;
        // add missing games
        for (NSString *key in [self.statuses allKeys]) {
            NSDictionary *row = [self rowForKey:key];
            if (!row) [self.rows addObject:[NSDictionary dictionaryWithObject:key forKey:@"key"]];
        }
        
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"rows.plist"];
        [self.rows writeToFile:filePath atomically:YES];

        [self.tableView reloadData];
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

- (IBAction)actions {
    UIBarButtonItem *item = self.navigationItem.leftBarButtonItem;
    NSArray *buttons = [NSArray arrayWithObjects:@"Open in Safari", @"Do you like this app?", @"Feedback", nil];
    [PLActionSheet actionSheetWithTitle:nil destructiveButtonTitle:nil buttons:buttons showFrom:item onDismiss:^(int buttonIndex){
        if (buttonIndex == 0) {
            [self openInSafari];
        } else if (buttonIndex == 1) {
            [self like];
        } else if (buttonIndex == 2) {
            [self feedback];
        }
    } onCancel:nil finally:nil];
}

- (IBAction)openInSafari {
    [PRPAlertView showWithTitle:@"Warning" message:@"This will open Mobile Safari with the SOE status page" cancelTitle:@"Cancel" cancelBlock:nil otherTitle:@"Continue" otherBlock:^(NSString *title){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.soe.com/status"]];
    }];
}

- (IBAction)like {
    UIBarButtonItem *item = self.navigationItem.leftBarButtonItem;
    NSArray *buttons = [NSArray arrayWithObjects:@"Review in App Store", @"Share by Twitter", @"Share by Email", nil];
    [PLActionSheet actionSheetWithTitle:nil destructiveButtonTitle:nil buttons:buttons showFrom:item onDismiss:^(int buttonIndex){
        if (buttonIndex == 0) {
            [self review];
        } else if (buttonIndex == 1) {
            [self shareByTwitter];
        } else if (buttonIndex == 2) {
            [self shareByEmail];
        }
    } onCancel:nil finally:nil];
}

- (IBAction)review {
    [[UIApplication sharedApplication] 
     openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=463597867"]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:21 forKey:@"launchCount"];
}

- (IBAction)shareByTwitter {
    if ([TWTweetComposeViewController canSendTweet]) {
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:@"I like this application and I think you should try it too."];
        [tweetSheet addURL:[NSURL URLWithString:@"http://itunes.com/app/soestatus"]];
        [self presentModalViewController:tweetSheet animated:YES];
    } else {
        [PRPAlertView showWithTitle:@"Twitter" message:@"Unable to send tweet: do you have an account set up?" cancelTitle:@"Continue" cancelBlock:nil otherTitle:nil otherBlock:nil];
    }
}

- (IBAction)shareByEmail {
    if (![MFMailComposeViewController canSendMail]) {
        [PRPAlertView showWithTitle:@"Mail error" message:@"This device is not configured to send email" buttonTitle:@"Continue"];
        return;
    }
    
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.modalPresentationStyle = UIModalPresentationFormSheet;
    mailer.mailComposeDelegate = self;
    
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
    NSString *appName = [bundleId pathExtension];
    appName = [appName capitalizedString];
        
    [mailer setSubject:appName];
    
    [mailer setMessageBody:@"I like this application and I think you should try it too. http://itunes.com/app/soestatus" isHTML:NO];
    
    // Present the mail composition interface.
    [self presentModalViewController:mailer animated:YES];
    [mailer release];

}

- (IBAction)feedback {
    if (![MFMailComposeViewController canSendMail]) {
        [PRPAlertView showWithTitle:@"Mail error" message:@"This device is not configured to send email" buttonTitle:@"Continue"];
        return;
    }
    
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.modalPresentationStyle = UIModalPresentationFormSheet;
    mailer.mailComposeDelegate = self;
    
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleIdentifierKey];
    NSString *appName = [bundleId pathExtension];
    appName = [appName capitalizedString];

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleVersionKey];
    
    [mailer setSubject:[@"Feedback About " stringByAppendingString:appName]];
    [mailer setToRecipients:[NSArray arrayWithObject:@"support@plsys.co.uk"]];
    
    NSString *body = [NSString stringWithFormat:@"AppID: %@\nVersion: %@\nLocale: %@\nDevice: %@\nOS: %@", bundleId, version, ((NSLocale *)[NSLocale currentLocale]).localeIdentifier, [UIDevice currentDevice].model, [UIDevice currentDevice].systemVersion];
    [mailer setMessageBody:body isHTML:NO];
    
    // Present the mail composition interface.
    [self presentModalViewController:mailer animated:YES];
    [mailer release];
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
        NSDictionary *row = [self rowForKey:key];
        if (row) {
            // game added to feed, but name comes from game.plist, which was updated later (by me)
            if (![row valueForKey:@"name"]) {
                [rows replaceObjectAtIndex:[rows indexOfObject:row] withObject:game];
            }
        } else {
            [rows addObject:game];
        }
    }
    
    // rater
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger launchCount = [prefs integerForKey:@"launchCount"];
    if (launchCount == 20) {
        launchCount++;
        [prefs setInteger:launchCount forKey:@"launchCount"];
        PRPAlertView *alert = [[PRPAlertView alloc] initWithTitle:@"Do you like this app?" message:@"Please rate it on the App Store!" cancelTitle:@"Never" cancelBlock:^(NSString *title){
            [prefs setInteger:21 forKey:@"launchCount"];
        } otherTitle:@"Rate now" otherBlock:^(NSString *title){
            if ([title isEqualToString:@"Rate now"]) {
                [self review];
            } else if ([title isEqualToString:@"Later"]) {
                [prefs setInteger:0 forKey:@"launchCount"];
            }
        }];
        [alert addButtonWithTitle:@"Later"];
        [alert show];
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

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    if (error) NSLog(@"%s error sending email, result %d: %@", __PRETTY_FUNCTION__, result, [error localizedDescription]);
    [self dismissModalViewControllerAnimated:YES];
}

@end
