//
//  AppDelegate.h
//  ChartbeatNotifier
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow *window;
  IBOutlet NSMenu *statusMenu;
  NSStatusItem *statusItem;
}

@property (assign) IBOutlet NSWindow *window;

@end
