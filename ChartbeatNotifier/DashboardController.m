//
//  DashboardController.m
//  ChartbeatNotifier

#import "DashboardController.h"

#import "Defines.h"

/** URL for the dashboard for a given domain */
NSString *const kDashboardURLFormat = @"http://chartbeat.com/dashboard/?url=%@&k=%@";

@implementation DashboardController
@synthesize webView;

- (id)init
{
  self = [super initWithWindowNibName:@"DashboardController"];    
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  [self loadDashboard];
}

-(void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation
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

- (void)loadDashboard
{
  NSLog(@"DashboardController.loadDashboard");

  // TODO: should get that from a pref controller or the app delegate?
  NSString *domain = [[NSUserDefaults standardUserDefaults] stringForKey:kPrefDomain];
  NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:kPrefApiKey];
  
  NSString *dashUrl = [NSMutableString stringWithFormat:kDashboardURLFormat, domain, apiKey];
  [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dashUrl]]];
}
@end
