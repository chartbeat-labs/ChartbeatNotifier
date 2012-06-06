//
//  AppDelegate.h
//  ChartbeatNotifier
//

#import <Cocoa/Cocoa.h>

#import <SBJson/SBJson.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  IBOutlet NSMenu *statusMenu;

  /** The status bar item */
  NSStatusItem *statusItem;

  /** JSON parser used to part API results */
  SBJsonParser *parser;

  /** Timer used to periodically update the counter */
  NSTimer *timer;
}

@property (unsafe_unretained) IBOutlet NSTextField *fieldApiKey;
@property (unsafe_unretained) IBOutlet NSTextField *fieldDomain;
@property (nonatomic) NSString *apiKey;

- (IBAction)actionQuit:(id)sender;

@end
