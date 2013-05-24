//
//  AppDelegate.m
//  ChartbeatNotifier
//

#import "AppDelegate.h"

#import <CoreFoundation/CoreFoundation.h>

#import "DashboardController.h"
#import "Account.h"
#import "Quickstats.h"
#import "Event.h"

int kEventMinutesAgo = 5;
/** How often to poll for event updates (seconds) */
NSTimeInterval const kEventInterval = (60 * 5);

NSString *const kGrowlEventNotificationName = @"Chartbeat Event";


@implementation AppDelegate

#pragma mark -
#pragma mark Properties

@synthesize preferencesWindowController = _preferencesWindowController;

#pragma mark -
#pragma mark Overridden methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    NSLog(@"applicationDidFinishLaunching()");

    dashboards = [[NSMutableDictionary alloc] init];

    Quickstats *sharedQuickstats = [Quickstats sharedInstance];
    [sharedQuickstats startUpdating];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusItemTitle:) name:@"QuickstatsUpdated" object:nil];
    
    _preferencesWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];

    // Set up Growl
    [GrowlApplicationBridge setGrowlDelegate:self];
    
    eventUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:kEventInterval
                                              target:self selector:@selector(checkForNewEvents:)
                                            userInfo:nil
                                             repeats:YES];
    [self checkForNewEvents:nil];

}

- (void)applicationWillTerminate:(NSApplication *)application
{
    NSLog(@"applicationWillTerminate()");
}

- (void)awakeFromNib
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setHighlightMode:YES];
    [statusItem setToolTip:@"Chartbeat Notifier"];
    [statusItem setMenu:statusMenu];
    [statusItem setImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"status" ofType:@"png"]]];
    [statusItem setAlternateImage:[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"activestatus" ofType:@"png"]]];
}

- (void)updateStatusItemTitle:(NSNotification *)notification {
    Quickstats *object = [notification object];
    NSString *displayedAttribute = [[Account sharedInstance] displayedAttribute];
    id displayedValue = [(Quickstats*)object valueForKey:displayedAttribute];
    NSString *newTitle = displayedValue;
    if ([displayedValue respondsToSelector:@selector(stringValue)]) {
        newTitle = [displayedValue stringValue];
    }
    [statusItem setTitle:newTitle];
}

#pragma mark -
#pragma mark Internal Methods

- (void)doOpenDashboard:(NSString *)aDomain
{
    NSLog(@"doOpenDashboard(%@)", aDomain);
    
    DashboardController *dashboard = [dashboards objectForKey:aDomain];
    if (!dashboard) {
        dashboard = [[DashboardController alloc] init];
        [dashboards setValue:dashboard forKey:aDomain];
    }
    [dashboard loadDashboard:aDomain apikey:[[Account sharedInstance] apiKey]];
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
    [self doOpenDashboard:[[Account sharedInstance] domain]];
}

- (IBAction)openPreferences:(id)sender {
//    NSLog(@"openPreferences()");
    [_preferencesWindowController showWindow:self];
}

#pragma mark -
#pragma mark Delegate Methods


- (void)checkForNewEvents:(NSTimer *)timer {
    static NSString *descriptionFormat = @"Just linked from %@";
    [Event getNewEvents:kEventMinutesAgo withBlock:^(NSArray *events, NSError *error) {
        for (Event *event in events) {
            if (![event.type isEqualToString:@"referrerpickup"]) {
                continue;
            }
            NSString *title = event.title;
            NSString *description = [NSString stringWithFormat:descriptionFormat,  event.value];
            
            [GrowlApplicationBridge notifyWithTitle:title
                                        description:description
                                   notificationName:kGrowlEventNotificationName
                                           iconData:nil
                                           priority:0
                                           isSticky:NO
                                       clickContext:nil
                                         identifier:nil];
        }
    }];
}

@end
