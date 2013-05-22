//
//  AppDelegate.h
//  ChartbeatNotifier
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate, NSWindowDelegate> {
  IBOutlet NSMenu *statusMenu;

  /** The status bar item */
  NSStatusItem *statusItem;
  
  /** Dashboard windows */
  // TODO: Is ownership correct? I.e. when the window is closed, this should be nulled out...
  NSDictionary *dashboards;
    
    NSTimer *eventUpdateTimer;
}

@property (unsafe_unretained) IBOutlet NSTextField *fieldApiKey;
@property (unsafe_unretained) IBOutlet NSTextField *fieldDomain;

- (IBAction)openDashboard:(id)sender;
- (IBAction)openDefaultDashboard:(id)sender;

@end
