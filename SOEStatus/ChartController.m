//
//  ChartController.m
//  SOEStatus
//
//  Created by Paul Lynch on 24/06/2014.
//  Copyright (c) 2014 P & L Systems. All rights reserved.
//

#import "ChartController.h"
#import "SOEGame.h"

@interface ChartController ()<UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;

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
    NSInteger x = 0;
    NSInteger increment = 5;
    NSArray *populationLevels = @[@"missing", @"low", @"medium", @"high"];
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
        NSNumber *population = [NSNumber numberWithInteger:[populationLevels indexOfObject:[sample valueForKey:@"status"]]];
        [series addObject:@{@"x": unixDate, @"y": population}];
        //NSLog(@"%@", [series lastObject]);
        x += increment;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:sampleDate];
        NSNumber *hour = [NSNumber numberWithInteger:[components hour]];
        if (summary[hour]) {
            summary[hour] = [NSNumber numberWithInteger:([summary[hour] integerValue] + [population integerValue])];
        } else {
            summary[hour] = population;
        }
    }
    NSDictionary *newSeries = @{@"data": series, @"color": @"palevioletred", @"name": self.server};
    
    NSString *dataString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:newSeries options:0 error:&error] encoding:NSUTF8StringEncoding];
    if (!dataString) {
        NSLog(@"Failed to convert data from server to Rickshaw format: %@", error);
    }
    
    // now convert summary to a series (don't really need to sort the keys, Rickshaw will take care of that)
    NSMutableArray *summaryHours = [NSMutableArray array];
    for (NSNumber *hour in [[summary allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        NSNumber *hourTotal = [summary objectForKey:hour];
        [summaryHours addObject:@{@"x": hour, @"y": [NSNumber numberWithDouble:([hourTotal doubleValue] / [summary count])]}];
    }
    NSDictionary *summarySeries = @{@"data": summaryHours, @"color": @"steelblue", @"name": self.server};
    
    NSString *summaryString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:summarySeries options:0 error:&error] encoding:NSUTF8StringEncoding];
    if (!summaryString) {
        NSLog(@"Failed to convert summary data from server to Rickshaw format: %@", error);
    }

    // assemble the HTML
	NSURL *baseURL = [[NSBundle mainBundle] URLForResource:@"HTML" withExtension:nil];
    NSString *htmlString = [self chartHtml];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%data%" withString:dataString options:NSLiteralSearch range:NSMakeRange(0, [htmlString length])];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%summary%" withString:summaryString options:NSLiteralSearch range:NSMakeRange(0, [htmlString length])];
    //NSLog(@"%@", htmlString);
    
    [self.webView loadHTMLString:htmlString baseURL:baseURL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSURL *historyUrlLocation = [NSURL URLWithString:@"http://paullynch.org/soe-status-url.txt"];
    NSString *historyUrl = @"http://54.88.120.46:3000";
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

@end
