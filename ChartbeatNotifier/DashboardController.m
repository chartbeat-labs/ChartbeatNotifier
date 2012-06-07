//
//  DashboardController.m
//  ChartbeatNotifier

#import "DashboardController.h"

#import "Defines.h"

/** URL for the dashboard for a given domain */
NSString *const kDashboardURLFormat = @"http://chartbeat.com/dashboard/?url=%@&k=%@";

/** Window title format */
NSString *const kTitleFormat = @"Dashboard: %@";


@implementation DashboardController
@synthesize webView;

#pragma mark -
#pragma mark Overridden functions

- (id)init
{
  self = [super initWithWindowNibName:@"DashboardController"];    
  return self;
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation
                                                          request:(NSURLRequest *)request frame:(WebFrame *)frame 
                                                 decisionListener:(id < WebPolicyDecisionListener >)listener
{
  NSString *host = [[request URL] host];
  if ([host isEqualToString:@"chartbeat.com"]) {
    [listener use];
  } else {
    [[NSWorkspace sharedWorkspace] openURL:[request URL]];
  }
}


#pragma mark -
#pragma mark Public functions
- (void)loadDashboard:(NSString *)aDomain apikey:(NSString *)aApiKey
{
  NSLog(@"DashboardController.loadDashboard(%@, %@)", aDomain, aApiKey);
  
  [self showWindow:nil];

  NSString *title = [NSString stringWithFormat:kTitleFormat, aDomain];
  [[self window] setTitle:title];
  
  NSString *dashUrl = [NSMutableString stringWithFormat:kDashboardURLFormat, aDomain, aApiKey];
  [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dashUrl]]];
}
@end
