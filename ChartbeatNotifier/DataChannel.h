//
//  DataChannel.h
//  ChartbeatNotifier
//
//  Created by Tom Germeau on 6/8/12.
//  Copyright (c) 2012 Betaworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Webkit/Webkit.h>

@interface DataChannel : NSWindowController {
  WebView *webView;
  NSStatusItem *statusItem;
}
//@property (unsafe_unretained) IBOutlet WebView *webView;
- (void)load:(NSString *)aDomain apikey:(NSString *)aApiKey statusItem:(NSStatusItem *)aStatusItem;

@end
