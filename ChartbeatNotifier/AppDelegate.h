//
//  AppDelegate.h
//  ChartbeatNotifier
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "PreferencesWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate, NSWindowDelegate> {
  IBOutlet NSMenu *statusMenu;

  /** The status bar item */
  NSStatusItem *statusItem;
  
  /** Dashboard windows */
  // TODO: Is ownership correct? I.e. when the window is closed, this should be nulled out...
  NSDictionary *dashboards;
    
    NSTimer *eventUpdateTimer;
}

@property (strong) PreferencesWindowController *preferencesWindowController;

- (IBAction)openDashboard:(id)sender;
- (IBAction)openDefaultDashboard:(id)sender;
- (IBAction)openPreferences:(id)sender;

@end
