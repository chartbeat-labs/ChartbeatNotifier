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
  if (true || [host isEqualToString:@"chartbeat.com"]) {
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

//this returns a nice name for the method in the JavaScript environment
+(NSString*)webScriptNameForSelector:(SEL)sel
{
  if(sel == @selector(logJavaScriptString:))
    return @"notify";
  return nil;
}

//this allows JavaScript to call the -logJavaScriptString: method
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
  if(sel == @selector(logJavaScriptString:))
    return NO;
  return YES;
}

//called when the nib objects are available, so do initial setup
- (void)awakeFromNib
{
  [webView setFrameLoadDelegate:self];
}


//this is a simple log command
- (void)logJavaScriptString:(NSString*) logText
{
  NSLog(@"HI: %@",logText);
}

//this is called as soon as the script environment is ready in the webview
- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
{
  [windowScriptObject setValue:self forKey:@"ChartbeatNative"];
}
@end
