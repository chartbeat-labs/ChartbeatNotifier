//
//  AppDelegate.m
//  ChartbeatNotifier
//

#import "AppDelegate.h"

@implementation AppDelegate

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

  parser = [[SBJsonParser alloc] init];

  timer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                           target:self selector:@selector(updateCounter:)
                                         userInfo:nil
                                          repeats:YES];
  [self setApiKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"apiKey"]];
  [self setDomain:[[NSUserDefaults standardUserDefaults] stringForKey:@"domain"]];
 
  NSString *dashUrl = [NSMutableString stringWithFormat:@"http://chartbeat.com/dashboard/?url=%@&k=%@", [self domain], [self apiKey]];
  [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dashUrl]]];
  
  // Kick off an update
  [self updateCounter:nil];
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

- (NSDictionary*)getJSON:(NSString *)aURL
{
  // TODO: add error handling galore
  // TODO: make async
  NSLog(@"getJSON(%@)", aURL);
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:aURL]];
  NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
  NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
  NSDictionary *data = [parser objectWithString:json_string error:nil];

  return data;
}

- (void)updateCounter:(NSTimer *)aTimer
{
  NSLog(@"updateCounter()");
  [statusItem setTitle:[self getSiteStats]];
}

- (NSString*)getTotalTotal
{
  NSLog(@"getTotalTotal()");
  
  NSDictionary *data = [self getJSON:@"http://api.chartbeat.com/cbtotal"];
  NSString *count = [data objectForKey:@"total"];

  return count;
}

- (NSString*)getSiteStats
{
  NSLog(@"getSiteStats()");
  
  NSString *url = [NSMutableString stringWithFormat:@"http://api.chartbeat.com/live/quickstats?apikey=%@&host=%@", [self apiKey], [self domain]];
  NSDictionary *data = [self getJSON:url];
  NSString *count = [data objectForKey:@"visits"];

  return count;
}


#pragma mark -
#pragma mark Actions

- (IBAction)actionQuit:(id)aSender
{
  NSLog(@"actionQuit()");
  
  [NSApp terminate: aSender];
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
