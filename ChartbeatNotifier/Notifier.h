//
//  Notifier.h
//  ChartbeatNotifier
//
//  Created by Tom Germeau on 6/7/12.
//  Copyright (c) 2012 Betaworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>

@interface Notifier : NSObject <GrowlApplicationBridgeDelegate> {
  /** True when we were abale to load the framework */
  bool growlAvailable;
}

- (void)notify:(NSString *)title: (NSString *)description;
- (void)notify:(NSString *)title;

+(Notifier*)getSingleton;
@end
