//
//  AppDelegate.m
//  ChartbeatNotifier
//

#import "AppDelegate.h"

@implementation AppDelegate

/** URL for the dashboard for a given domain */
NSString *const kDashboardURLFormat = @"http://chartbeat.com/dashboard/?url=%@&k=%@";

/** URL for site stats for a givem domain */
NSString *const kSiteStatsFormat = @"http://api.chartbeat.com/live/quickstats?apikey=%@&host=%@";

/** How often to update the site stats (seconds) */
NSTimeInterval const kRequestInterval = 3;

/** Timeout for site stats request (seconds) */
NSTimeInterval const kRequestTimeoutInterval = 2;

#pragma mark -
#pragma mark Properties

@synthesize fieldDomain;
@synthesize webView;
@synthesize fieldApiKey;


#pragma mark -
#pragma mark Public methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  NSLog(@"applicationDidFinishLaunching()");

  receivedData = [NSMutableData data];

  parser = [[SBJsonParser alloc] init];

  timer = [NSTimer scheduledTimerWithTimeInterval:kRequestInterval
                                           target:self selector:@selector(updateCounter:)
                                         userInfo:nil
                                          repeats:YES];
  [self setApiKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"]];
  [self setDomain:[[NSUserDefaults standardUserDefaults] stringForKey:@"domain"]];
  
  // Load the dashboard into the webview (really should do on load...)
  [self loadDashboard];
  
  // Kick off an update
  [self getSiteStats];
}

- (void)applicationWillTerminate:(NSApplication *)application
{
  NSLog(@"applicationWillTerminate()");
  
  // TODO: generalize
  [[NSUserDefaults standardUserDefaults] setValue:[self apiKey] forKey:@"apiKey"];
  [[NSUserDefaults standardUserDefaults] setValue:[self domain] forKey:@"domain"];
}

- (void)awakeFromNib
{
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [statusItem setMenu:statusMenu];
  [statusItem setTitle:@"(loading)"];
  [statusItem setHighlightMode:YES];
}


#pragma mark -
#pragma mark Internal Methods

/** loads the dashboard in the webview */
- (void)loadDashboard
{
  if (!([[self domain] length] && [[self apiKey] length])) {
    return;
  }

  NSString *dashUrl = [NSMutableString stringWithFormat:kDashboardURLFormat, [self domain], [self apiKey]];
  [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dashUrl]]];
    
}

/** called by the timer when the stats counter needs to get updated */
- (void)updateCounter:(NSTimer *)aTimer
{
  NSLog(@"updateCounter()");
  [self getSiteStats];
}

/** Initiate getting fresh site stats from the backend */
- (void)getSiteStats
{
  NSLog(@"getSiteStats()");
  
  NSString *url = [NSMutableString stringWithFormat:kSiteStatsFormat, [self apiKey], [self domain]];
  
  // TODO: don't kick off if previous load is still running
  // TODO: display errors to user
  [self loadRequest:url];
}


#pragma mark -
#pragma mark Request Handling
- (void)loadRequest:(NSString *)aURL
{
  NSLog(@"loadRequest: %@", aURL);

  NSURLRequest *theRequest;
  theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:aURL]
                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                            timeoutInterval:kRequestTimeoutInterval];

  // TODO: who owns this?
  NSURLConnection *theConnection;
  theConnection = [[NSURLConnection alloc] initWithRequest:theRequest 
                                                  delegate:self];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
  NSLog(@"didReceiveResponse()");
  
  [receivedData setLength:0];

  if (![response isKindOfClass: [NSHTTPURLResponse class]]) {
    return;
  }
  
  int statusCode = [(NSHTTPURLResponse*) response statusCode];
  if (statusCode != 200) {
    NSLog(@"Got non-200 response code: %d (%@)",
          statusCode,
          [response URL]);
    return;
  }
  
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  NSLog(@"didReceiveData()");

  [receivedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
  NSLog(@"Request error: %@ (%@)",
        [error localizedDescription],
        [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
  
  connection = nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSLog(@"connectionDidFinishLoading()");
  
  connection = nil;

  NSString *json_string = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
  [receivedData setLength:0];

  NSDictionary *data = [parser objectWithString:json_string error:nil];
  NSString *count = [data objectForKey:@"visits"];
  [statusItem setTitle:count];
}


#pragma mark -
#pragma mark Preference properties
// TODO: move all this to a separate class

- (NSString*)apiKey
{
  return [self.fieldApiKey stringValue];
}

- (void)setApiKey:(NSString *)aApiKey
{
  [self.fieldApiKey setStringValue:aApiKey];
}

- (NSString*)domain
{
  return [self.fieldDomain stringValue];
}

- (void)setDomain:(NSString *)aDomain
{
  [self.fieldDomain setStringValue:aDomain];
}

@end
