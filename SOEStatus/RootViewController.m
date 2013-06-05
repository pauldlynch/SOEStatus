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
#import "ServerViewController.h"
#import "PLActionSheet.h"
#import <Twitter/Twitter.h>
#import "SOEGame.h"

NSString *SOEGameSelectedNotification = @"SOEGameSelectedNotification";

@implementation RootViewController

@synthesize statuses;

- (void)refresh {    
    [SOEStatusAPI getStatuses:^(PLRestful *api, id object, int status, NSError *error){
        if (error) {
            NSLog(@"API Error: %@", error);
            NSString *message = [NSString stringWithFormat:@"%@", [error localizedDescription]];
            [PRPAlertView showWithTitle:@"API Error" message:message buttonTitle:@"Continue"];
            //return;
        }
        [SOEGame updateWithStatuses:object];
        
        self.contentSizeForViewInPopover = CGSizeMake(self.contentSizeForViewInPopover.width, 44.0 * [[SOEGame games] count]);
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (void)editing {
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
    if (self.tableView.isEditing) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editing)];
        self.navigationItem.rightBarButtonItem = doneButton;
    } else {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editing)];
        self.navigationItem.rightBarButtonItem = editButton;
        [SOEGame save];
    }
}

- (IBAction)actions {
    UIBarButtonItem *item = self.navigationItem.leftBarButtonItem;
    NSArray *buttons = [NSArray arrayWithObjects:@"Open in Safari", @"Do you like this app?", @"Feedback", nil];
    [PLActionSheet actionSheetWithTitle:nil destructiveButtonTitle:nil buttons:buttons showFrom:item onDismiss:^(int buttonIndex){
        if (buttonIndex == [buttons indexOfObject:@"Open in Safari"]) {
            [self openInSafari];
        } else if (buttonIndex == [buttons indexOfObject:@"Do you like this app?"]) {
            [self like];
        } else if (buttonIndex == [buttons indexOfObject:@"Feedback"]) {
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
    NSArray *buttons = [NSArray arrayWithObjects:@"Review in App Store", @"Share by Twitter", @"Share by Facebook", @"Share by Email", nil];
    [PLActionSheet actionSheetWithTitle:nil destructiveButtonTitle:nil buttons:buttons showFrom:item onDismiss:^(int buttonIndex){
        if (buttonIndex == 0) {
            [self review];
        } else if (buttonIndex == 1) {
            [self shareByTwitter];
        } else if (buttonIndex == 2) {
            [self shareByFacebook];
        } else if (buttonIndex == 3) {
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
    if (NSClassFromString(@"SLComposeViewController")) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *tweetVC =
            [SLComposeViewController composeViewControllerForServiceType:
             SLServiceTypeTwitter];
            [tweetVC setInitialText:@"I like this application and I think you should try it too."];
            [tweetVC addURL:[NSURL URLWithString:@"http://itunes.com/app/soestatus"]];
            [self presentViewController:tweetVC animated:YES completion:NULL];
        } else {
            [PRPAlertView showWithTitle:@"Twitter" message:@"Unable to send tweet: do you have an account set up?" cancelTitle:@"Continue" cancelBlock:nil otherTitle:nil otherBlock:nil];
        }
    } else {
        if ([TWTweetComposeViewController canSendTweet]) {
            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
            [tweetSheet setInitialText:@"I like this application and I think you should try it too."];
            [tweetSheet addURL:[NSURL URLWithString:@"http://itunes.com/app/soestatus"]];
            tweetSheet.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:tweetSheet animated:YES completion:nil];
        } else {
            [PRPAlertView showWithTitle:@"Twitter" message:@"Unable to send tweet: do you have an account set up?" cancelTitle:@"Continue" cancelBlock:nil otherTitle:nil otherBlock:nil];
        }
    }
}

- (IBAction)shareByFacebook {
    if (NSClassFromString(@"SLComposeViewController")) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *fbVC =
            [SLComposeViewController composeViewControllerForServiceType:
             SLServiceTypeFacebook];
            [fbVC setInitialText:@"I like this application and I think you should try it too."];
            [fbVC addURL:[NSURL URLWithString:@"http://itunes.com/app/soestatus"]];
            [self presentViewController:fbVC animated:YES completion:NULL];
        } else {
            [PRPAlertView showWithTitle:@"Facebook" message:@"Unable to post to Facebook: do you have an account set up?" cancelTitle:@"Continue" cancelBlock:nil otherTitle:nil otherBlock:nil];
        }
    } else {
        [PRPAlertView showWithTitle:@"Facebook" message:@"Posting to Facebook isn't available on this version of iOS" buttonTitle:@"Continue"];
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
    mailer.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:mailer animated:YES completion:nil];

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
    mailer.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:mailer animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Games";
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editing)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    UIBarButtonItem *actionsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actions)];
    self.navigationItem.leftBarButtonItem = actionsButton;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
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
    
    self.contentSizeForViewInPopover = CGSizeMake(self.contentSizeForViewInPopover.width, 44.0 * [[SOEGame games] count]);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
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
    return [[SOEGame games] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Configure the cell.
    SOEGame *game = [[SOEGame games] objectAtIndex:indexPath.row];
    cell.textLabel.text = game.name ? game.name : game.key;
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
        [SOEGame removeGame:[[SOEGame games] objectAtIndex:indexPath.row ]];
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
    [SOEGame moveGameFromIndex:fromIndexPath.row to:toIndexPath.row];
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
    SOEGame *game = [[SOEGame games] objectAtIndex:indexPath.row];
    detailViewController.gameId = game.key;
    detailViewController.title = game.name;
    [self.navigationController pushViewController:detailViewController animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:SOEGameSelectedNotification object:self userInfo:@{@"game": game}];
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


#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    if (error) NSLog(@"%s error sending email, result %d: %@", __PRETTY_FUNCTION__, result, [error localizedDescription]);
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
