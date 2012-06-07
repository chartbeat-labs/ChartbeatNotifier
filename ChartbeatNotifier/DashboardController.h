//
//  DashboardController.h
//  ChartbeatNotifier
//
//  Window controller for showing a Chartbeat dashboard for a given site.
//

#import <Cocoa/Cocoa.h>
#import <Webkit/Webkit.h>

@interface DashboardController : NSWindowController
@property (unsafe_unretained) IBOutlet WebView *webView;

@end
