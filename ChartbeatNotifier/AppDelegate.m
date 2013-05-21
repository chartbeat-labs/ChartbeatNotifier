//
//  AppDelegate.m
//  ChartbeatNotifier
//

#import "AppDelegate.h"

#import <CoreFoundation/CoreFoundation.h>

#import "DashboardController.h"
#import "Defines.h"

/** If not defined, the status item counter will never be updated */
#define UPDATE_COUNTER

@implementation AppDelegate

/** How often to update the site stats (seconds) */
NSTimeInterval const kRequestInterval = 3;

/** Timeout for site stats request (seconds) */
NSTimeInterval const kRequestTimeoutInterval = 2;

#pragma mark -
#pragma mark Properties

@synthesize fieldDomain;
@synthesize fieldApiKey;


#pragma mark -
#pragma mark Overridden methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  NSLog(@"applicationDidFinishLaunching()");

  receivedData = [NSMutableData data];
  dashboards = [[NSMutableDictionary alloc] init];
  parser = [[SBJsonParser alloc] init];

  [self setApiKey:[[NSUserDefaults standardUserDefaults] stringForKey:kPrefApiKey]];
  [self setDomain:[[NSUserDefaults standardUserDefaults] stringForKey:kPrefDomain]];

#ifdef UPDATE_COUNTER
  timer = [NSTimer scheduledTimerWithTimeInterval:kRequestInterval
                                           target:self selector:@selector(updateCounter:)
                                         userInfo:nil
                                          repeats:YES];
  
  // Kick off an update
  [self getSiteStats];
#endif

  // Set up Growl
  [GrowlApplicationBridge setGrowlDelegate:self];
}

- (void)applicationWillTerminate:(NSApplication *)application
{
  NSLog(@"applicationWillTerminate()");
  
  // TODO: generalize
  [[NSUserDefaults standardUserDefaults] setValue:[self apiKey] forKey:kPrefApiKey];
  [[NSUserDefaults standardUserDefaults] setValue:[self domain] forKey:kPrefDomain];
}

- (void)awakeFromNib
{
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [statusItem setHighlightMode:YES];
  [statusItem setMenu:statusMenu];
  [statusItem setTitle:@"(loading)"];
  [statusItem setImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"status" ofType:@"png"]]];
  [statusItem setAlternateImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"activestatus" ofType:@"png"]]];
}

#pragma mark -
#pragma mark Internal Methods

- (NSDictionary*) registrationDictionaryForGrowl
{
    NSString* path = [[NSBundle mainBundle] pathForResource: @"Growl Registration Ticket" ofType: @"growlRegDict"];
    NSDictionary* dictionary = [NSDictionary dictionaryWithContentsOfFile: path];
    return dictionary;
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

/** Parses the given JSON, and sets the statusItem title to the current site total */
- (void)setTitle:(NSString *)aJsonString
{
  NSDictionary *data = [parser objectWithString:aJsonString error:nil];
  NSNumber *count = [data objectForKey:@"visits"];
  NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
  [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
  [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
  NSString *title = [numberFormatter stringFromNumber:count];
  [statusItem setTitle:title];
}


#pragma mark -
#pragma mark Request Handling
// TODO: move all this to a separate class

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

  [self setTitle:json_string];
}

- (void)doOpenDashboard:(NSString *)aDomain
{
  NSLog(@"doOpenDashboard(%@)", aDomain);

  DashboardController *dashboard = [dashboards objectForKey:aDomain];
  if (!dashboard) {
    dashboard = [[DashboardController alloc] init];
    [dashboards setValue:dashboard forKey:aDomain];
  }
  [dashboard loadDashboard:aDomain apikey:[self apiKey]];
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

#pragma mark -
#pragma mark Actions

- (IBAction)openDashboard:(id)sender
{
  NSLog(@"openDashboard()");

  // TODO: super ugly, build own...
  // Ask user for domain the to open
  SInt32 error = 0;
  NSDictionary *dict = [[NSMutableDictionary alloc] init];
  [dict setValue:@"Dashboard" forKey:(NSString*) kCFUserNotificationAlertHeaderKey];
  [dict setValue:@"Domain:" forKey:(NSString*) kCFUserNotificationTextFieldTitlesKey];
  CFDictionaryRef cfdict = (__bridge CFDictionaryRef) dict;
  CFUserNotificationRef notifier = CFUserNotificationCreate (kCFAllocatorDefault, 0, kCFUserNotificationPlainAlertLevel, &error, cfdict);
  CFOptionFlags flags;
  CFUserNotificationReceiveResponse (notifier, 0, &flags);
  
  CFStringRef domain = CFUserNotificationGetResponseValue(notifier, kCFUserNotificationTextFieldValuesKey , 0);
  
  [self doOpenDashboard:(__bridge NSString*) domain];
}

- (IBAction)openDefaultDashboard:(id)sender
{
  NSLog(@"openDefaultDashboard()");
  [self doOpenDashboard:[self domain]];
}

@end
