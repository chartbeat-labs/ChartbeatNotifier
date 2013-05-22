//
//  AppDelegate.m
//  ChartbeatNotifier
//

#import "AppDelegate.h"

#import <CoreFoundation/CoreFoundation.h>

#import "DashboardController.h"
#import "Defines.h"
#import "Account.h"
#import "Quickstats.h"

@implementation AppDelegate

#pragma mark -
#pragma mark Properties

@synthesize fieldDomain;
@synthesize fieldApiKey;


#pragma mark -
#pragma mark Overridden methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"applicationDidFinishLaunching()");

    dashboards = [[NSMutableDictionary alloc] init];
    
    Account *sharedAccount = [Account sharedInstance];
    [self.fieldApiKey setStringValue:sharedAccount.apiKey];
    [self.fieldDomain setStringValue:sharedAccount.domain];

    Quickstats *sharedQuickstats = [Quickstats sharedInstance];
    [sharedQuickstats startUpdating];
    [sharedQuickstats addObserver:self forKeyPath:@"formattedVisits" options:0 context:nil];

    // Set up Growl
    [GrowlApplicationBridge setGrowlDelegate:self];
    
//    [GrowlApplicationBridge notifyWithTitle:title
//                                description:description
//                           notificationName:kNotificationName
//                                   iconData:(NSData *)nil
//                                   priority:0
//                                   isSticky:YES
//                               clickContext:nil
//                                 identifier:description];

}

- (void)applicationWillTerminate:(NSApplication *)application
{
    NSLog(@"applicationWillTerminate()");
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change    context:(void *)context {
    if ([keyPath isEqualToString:@"formattedVisits"]) {
        [statusItem setTitle:[(Quickstats*)object formattedVisits]];
    }
}

#pragma mark -
#pragma mark Internal Methods

- (NSDictionary*) registrationDictionaryForGrowl
{
    NSString* path = [[NSBundle mainBundle] pathForResource: @"Growl Registration Ticket" ofType: @"growlRegDict"];
    NSDictionary* dictionary = [NSDictionary dictionaryWithContentsOfFile: path];
    return dictionary;
}

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

#pragma mark -
#pragma mark Delegate Methods

// only used for Preferences Window
// TODO: abstract into own controller
- (void)windowWillClose:(NSNotification *)notification {
    NSLog(@"windowWillClose()");
    [[Account sharedInstance] setApiKey:[self.fieldApiKey stringValue]];
    [[Account sharedInstance] setDomain:[self.fieldDomain stringValue]];
}

@end
