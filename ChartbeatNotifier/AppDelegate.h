//
//  AppDelegate.h
//  ChartbeatNotifier
//

#import <Cocoa/Cocoa.h>

#import "SBJson.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow *window;
  IBOutlet NSMenu *statusMenu;

  /** The status bar item */
  NSStatusItem *statusItem;

  /** JSON parser used to part API results */
  SBJsonParser *parser;

  /** Timer used to periodically update the counter */
  NSTimer *timer;
}

@property (assign) IBOutlet NSWindow *window;

@end
