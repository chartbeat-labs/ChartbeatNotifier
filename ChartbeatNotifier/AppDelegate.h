//
//  AppDelegate.h
//  ChartbeatNotifier
//

#import <Cocoa/Cocoa.h>
#import <SBJson/SBJson.h>
#import <Growl/Growl.h>

#import "DashboardController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate> {
  IBOutlet NSMenu *statusMenu;

  /** The status bar item */
  NSStatusItem *statusItem;

  /** JSON parser used to part API results */
  SBJsonParser *parser;

  /** Timer used to periodically update the counter */
  NSTimer *timer;

  /** Used to receive backend data */
  NSMutableData *receivedData;
  
  /** Default dashboard window */
  // TODO: Is ownership correct? I.e. when the window is closed, this should be nulled out...
  DashboardController *dashboard;

  /** Dashboard window */
  // TODO: Is ownership correct? I.e. when the window is closed, this should be nulled out...
  // TODO: maintain a list of windows? There must be a way for the window to hold on to a ref to itself until closed.
  DashboardController *otherDashboard;

  /** True when we were abale to load the framework */
  bool growlAvailable;
}

@property (unsafe_unretained) IBOutlet NSTextField *fieldApiKey;
@property (unsafe_unretained) IBOutlet NSTextField *fieldDomain;

@property NSString *domain;
@property NSString *apiKey;

- (IBAction)openDashboard:(id)sender;
- (IBAction)openDefaultDashboard:(id)sender;

@end
