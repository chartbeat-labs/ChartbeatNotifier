//
//  Notifier.h
//  ChartbeatNotifier
//
//  Created by Tom Germeau on 6/7/12.
//  Copyright (c) 2012 Betaworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>

@interface Notifier : NSObject {
  /** True when we were abale to load the framework */
  bool growlAvailable;
}

//@property (unsafe_unretained) IBOutlet WebView *webView;
//-(void) loadDashboard:(NSString *)aDomain apikey:(NSString *)aApiKey;

@end
