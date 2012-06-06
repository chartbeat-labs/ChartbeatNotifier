//
//  AppDelegate.m
//  ChartbeatNotifier
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  parser = [[SBJsonParser alloc] init];

  timer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                           target:self selector:@selector(updateCounter:)
                                         userInfo:nil
                                          repeats:YES];
  [self updateCounter:nil];
}

-(void)awakeFromNib
{
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [statusItem setMenu:statusMenu];
  [statusItem setTitle:@"(loading)"];
  [statusItem setHighlightMode:YES];
}

-(NSDictionary*)getJSON:(NSString*)aURL
{
  // TODO: add error handling galore
  NSLog(@"getJSON(%@)", aURL);
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:aURL]];
  NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
  NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
  NSDictionary *data = [parser objectWithString:json_string error:nil];

  return data;
}

-(void)updateCounter:(NSTimer*)aTimer
{
  NSLog(@"updateCounter()");

  NSDictionary *data = [self getJSON:@"http://api.chartbeat.com/cbtotal"];
  NSString *totaltotal = [data objectForKey:@"total"];

  NSMutableString  *title = [NSMutableString stringWithFormat:@"Total: %@", totaltotal];
  NSLog(@"%@", title);

  [statusItem setTitle:title];
}


@end
