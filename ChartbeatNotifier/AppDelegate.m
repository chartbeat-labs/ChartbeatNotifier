//
//  AppDelegate.m
//  ChartbeatNotifier
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

-(void)awakeFromNib{
  statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  [statusItem setMenu:statusMenu];
  [statusItem setTitle:@"Status"];
  [statusItem setHighlightMode:YES];
}

@end
