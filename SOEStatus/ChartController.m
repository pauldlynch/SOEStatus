//
//  ChartController.m
//  SOEStatus
//
//  Created by Paul Lynch on 24/06/2014.
//  Copyright (c) 2014 P & L Systems. All rights reserved.
//

#import "ChartController.h"
#import "SOEGame.h"

@interface ChartController ()<UIWebViewDelegate, UIDocumentInteractionControllerDelegate, UIBarPositioningDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) UIDocumentInteractionController *shareController;

- (IBAction)shareAsImage:(id)sender;

@end

@implementation ChartController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setServer:(NSString *)name {
    _server = name;
    self.title = name;
}

- (void)loadDataForGameCode:(NSString *)code server:(NSString *)server {
    self.gameCode = code;
    self.server = server;
    
    SOEGame *game = [SOEGame gameForKey:code];
    if (game && game.name) {
        self.title = [NSString stringWithFormat:@"%@/%@", game.name, server];
    } else {
        self.title = [NSString stringWithFormat:@"%@/%@", code, server];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.historyURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"game=%@&server=%@", self.gameCode, self.server];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && error == nil) {
            [self loadDataIntoChart:data];
        } else if ([data length] == 0 && error == nil) {
            NSLog(@"No data received from server: %@", request);
            [[[UIAlertView alloc] initWithTitle:@"Unable to load server history" message:@"Request returned no data." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil] show];
        } else if (error != nil && error.code == NSURLErrorTimedOut) {
            [[[UIAlertView alloc] initWithTitle:@"Unable to load server history" message:@"Request timed out." delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil] show];
        } else if (error != nil) {
            NSString *message = [error localizedDescription];
            [[[UIAlertView alloc] initWithTitle:@"Unable to load server history" message:message delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil] show];
        }
    }];
}

- (NSString *)chartHtml {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"line-chart" withExtension:@"html" subdirectory:@"HTML"];
    NSError *error;
    NSString *htmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (!htmlString) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
        [[[UIAlertView alloc] initWithTitle:@"Unable to load HTML" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil] show];
    }
    return htmlString;
}

- (void)loadDataIntoChart:(NSData *)data {
    if (!data) {
        NSLog(@"Server request returned no data.");
    }
    
    NSError *error;
    NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!jsonData) {
        NSLog(@"%@ is either not responding or corrupted: %@", self.historyURL, error);
        jsonData = @[];
    }
    
    //   "sample_date" : "2014-06-25T17:55:51.000Z",
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSInteger x = 0;
    NSInteger increment = 5;
    NSDictionary *populationLevels = @{@"locked": @0, @"missing": @0, @"down": @0, @"low": @1, @"medium": @2, @"high": @3};
    NSMutableArray *series = [NSMutableArray array];
    NSMutableDictionary *summary = [NSMutableDictionary dictionary];
    for (NSDictionary *sample in jsonData) {
        NSString *sampleDateString = [sample valueForKey:@"sample_date"];
        NSDate *sampleDate = [dateFormatter dateFromString:sampleDateString];
        if (!sampleDate) {
            NSLog(@"Failed to get date (%@): '%@'", [dateFormatter dateFormat], sampleDateString);
        }
        NSNumber *unixDate = [NSNumber numberWithDouble:[sampleDate timeIntervalSince1970]];
        // @"x": [NSNumber numberWithInteger:x]
        NSNumber *population = populationLevels[[sample valueForKey:@"status"]];
        if (!population) {
            NSLog(@"missing population type: %@", [sample valueForKey:@"status"]);
            population = @0;
        }
        [series addObject:@{@"x": unixDate, @"y": population}];
        //NSLog(@"%@", [series lastObject]);
        x += increment;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:sampleDate];
        NSNumber *hour = [NSNumber numberWithInteger:[components hour]];
        if (!summary[hour]) {
            summary[hour] = @{@"y": @0, @"n": @0};
        }
        NSDictionary *oldHour = summary[hour];
        summary[hour] = @{@"y": [NSNumber numberWithInteger:[oldHour[@"y"] integerValue] + [population integerValue]],
                          @"n": [NSNumber numberWithInteger:[oldHour[@"n"] integerValue] + 1]};
    }
    NSDictionary *newSeries = @{@"data": series, @"color": @"palevioletred", @"name": self.server};
    
    NSString *dataString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:newSeries options:0 error:&error] encoding:NSUTF8StringEncoding];
    if (!dataString) {
        NSLog(@"Failed to convert data from server to Rickshaw format: %@", error);
    }
    
    // now convert summary to a series (don't really need to sort the keys, Rickshaw will take care of that)
    NSMutableArray *summaryHours = [NSMutableArray array];
    for (NSNumber *hour in [[summary allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        NSNumber *hourTotal = [summary objectForKey:hour][@"y"];
        NSInteger hourInt = [[summary objectForKey:hour][@"n"] integerValue];
        if (hourInt > 0) {  // zero will force a crash (division by zero)
            [summaryHours addObject:@{@"x": hour, @"y": [NSNumber numberWithDouble:([hourTotal doubleValue] / hourInt)]}];
        }
    }
    NSDictionary *summarySeries = @{@"data": summaryHours, @"color": @"steelblue", @"name": self.server};
    
    NSData *summaryData = [NSJSONSerialization dataWithJSONObject:summarySeries options:0 error:&error];
    NSString *summaryString = nil;
    if (summaryData) {
        summaryString = [[NSString alloc] initWithData:summaryData encoding:NSUTF8StringEncoding];
        if (!summaryString) {
            NSLog(@"Failed to convert summary data from server to Rickshaw format: %@", error);
        }
    } else {
        NSLog(@"Bad summary data sent from server: %@", error);
    }

    // assemble the HTML
	NSURL *baseURL = [[NSBundle mainBundle] URLForResource:@"HTML" withExtension:nil];
    NSString *htmlString = [self chartHtml];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%data%" withString:dataString options:NSLiteralSearch range:NSMakeRange(0, [htmlString length])];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%summary%" withString:summaryString options:NSLiteralSearch range:NSMakeRange(0, [htmlString length])];
    //NSLog(@"%@", htmlString);
    
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
}

-(NSURL *)createPDFfromUIView:(UIView *)aView saveToDocumentsWithFileName:(NSString*)aFilename {
    // Creates a mutable data object for updating with binary data, like a byte array
    UIWebView *webView = (UIWebView *)aView;
    NSString *heightStr = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    int height = [heightStr intValue];
    height = 660;
    //  CGRect screenRect = [[UIScreen mainScreen] bounds];
    //  CGFloat screenHeight = (self.contentWebView.hidden)?screenRect.size.width:screenRect.size.height;
    CGFloat screenHeight = webView.bounds.size.height;
    int pages = ceil(height / screenHeight);
    
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, webView.bounds, nil);
    CGRect frame = [webView frame];
    for (int i = 0; i < pages; i++) {
        // Check to screenHeight if page draws more than the height of the UIWebView
        if ((i+1) * screenHeight  > height) {
            CGRect f = [webView frame];
            f.size.height -= (((i+1) * screenHeight) - height);
            [webView setFrame: f];
        }
        
        UIGraphicsBeginPDFPage();
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        //      CGContextTranslateCTM(currentContext, 72, 72); // Translate for 1" margins
        
        [[[webView subviews] lastObject] setContentOffset:CGPointMake(0, screenHeight * i) animated:NO];
        [webView.layer renderInContext:currentContext];
    }
    
    UIGraphicsEndPDFContext();
    // Retrieves the document directories from the iOS device
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString* documentDirectory = [documentDirectories objectAtIndex:0];
    NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:aFilename];
    
    // instructs the mutable data object to write its context to a file on disk
    [pdfData writeToFile:documentDirectoryFilename atomically:YES];
    [webView setFrame:frame];
    
    return [NSURL fileURLWithPath:documentDirectoryFilename];
}

- (UIImage *)imageFromScrollView:(UIScrollView *)scrollView {
    UIImage *img = nil;
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, scrollView.opaque, 0.0);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        [scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
        img = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    return img;
}

-(NSURL *)createImagefromUIView:(UIView *)aView saveToDocumentsWithFileName:(NSString*)aFilename {
    UIImage *img = nil;
    // iOS version >= 5.0
    if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending) {
        [self imageFromScrollView:self.webView.scrollView];
    } else {
        for (id subview in self.webView.subviews) {
            if ([subview isKindOfClass:[UIScrollView class]]) {
                [self imageFromScrollView:subview];
            }
        }
    }
    
    // Retrieves the document directories from the iOS device
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString* documentDirectory = [documentDirectories objectAtIndex:0];
    NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:aFilename];
    
    // instructs the mutable data object to write its context to a file on disk
    [UIImagePNGRepresentation(img) writeToFile:documentDirectoryFilename atomically:YES];
    
    return [NSURL fileURLWithPath:documentDirectoryFilename];
}

- (IBAction)shareAsImage:(id)sender {
    NSString *fileName = [NSString stringWithFormat:@"%@ %@", self.gameCode, self.server];
    NSURL *pdfURL = [self createPDFfromUIView:self.webView saveToDocumentsWithFileName:fileName];
    self.shareController = [UIDocumentInteractionController interactionControllerWithURL:pdfURL];
    self.shareController.delegate = self;
    self.shareController.UTI = @"com.adobe.pdf";
    [self.shareController presentOptionsMenuFromBarButtonItem:sender animated:YES];
}

#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationBar setItems:@[self.navigationItem] animated:NO];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAsImage:)];
    
    NSURL *historyUrlLocation = [NSURL URLWithString:@"https://paullynch.org/soe-status-url.txt"];
    // NSString *historyUrl = @"http://54.88.120.46:3000";
    // NSString *historyUrl = @"http://52.4.164.117:3001";
    // NSString *historyUrl = @"http://52.1.155.132:3001";    
    // NSString *historyUrl = @"http://52.7.81.172:3001";
    
     NSString *historyUrl = @"http://52.44.254.4:3001";

  
    
    NSData *data = [NSData dataWithContentsOfURL:historyUrlLocation];
    if (data) {
        historyUrl = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%s history url found: '%@'", __PRETTY_FUNCTION__, historyUrl);
    }
    self.historyURL = [NSURL URLWithString:historyUrl];
    
    [self loadDataForGameCode:self.gameCode server:self.server];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = [[request URL] absoluteString];
    NSLog(@"URL: %@", urlString);

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, error);
}

#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *) controller {
}

- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *) controller {
}

#pragma mark UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
