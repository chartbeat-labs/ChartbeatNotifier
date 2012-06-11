//
//  Notifier.h
//  ChartbeatNotifier
//
//  Created by Tom Germeau on 6/7/12.
//  Copyright (c) 2012 Betaworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>

@class MAAttachedWindow;

@interface Notifier : NSObject <GrowlApplicationBridgeDelegate> {
  /** True when we were abale to load the framework */
  bool growlAvailable;
  
  /** our own popup window if we need it */
  MAAttachedWindow *attachedWindow;
  NSStatusItem *statusItem;

  IBOutlet NSView *view;
}

- (void)notify:(NSString *)title: (NSString *)description;
- (void)notify:(NSString *)title;
- (void)setStatusItem:(NSStatusItem*) item;

+(Notifier*)getSingleton;
@end
