//
//  Notifier.m
//  ChartbeatNotifier
//
//  Created by Tom Germeau on 6/7/12.
//  Copyright (c) 2012 Betaworks. All rights reserved.
//

#import "Notifier.h"


@implementation Notifier

static Notifier *_sharedNotifier = nil;

+(Notifier*)getSingleton
{
  if (!_sharedNotifier) {
    _sharedNotifier = [[self alloc] init];
  }
  return _sharedNotifier;
}

- (id)init {
  self = [super init];
  [self loadGrowl];
  return self;
}


- (void)loadGrowl
{
  NSBundle *myBundle = [NSBundle bundleForClass:[Notifier class]];
  NSString *growlPath = [[myBundle privateFrameworksPath]
                         stringByAppendingPathComponent:@"Growl.framework"];
  NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
  
  if (growlBundle && [growlBundle load]) {
    [GrowlApplicationBridge setGrowlDelegate:self];
    growlAvailable = true;
  } else {
    NSLog(@"Could not load Growl.framework");
    growlAvailable = false;
  }
  
}
- (void)notify:(NSString *)title
{
  [self notify:title :@""];
}

- (void)notify:(NSString *)title: (NSString *)description
{    
  if (!growlAvailable) {
    return;
  }
  //	if([GAB respondsToSelector:@selector(notifyWithTitle:description:notificationName:iconData:priority:isSticky:clickContext:identifier:)]) {   
  //    }
  Class growl = NSClassFromString(@"GrowlApplicationBridge");
  [growl notifyWithTitle:title
             description:description
        notificationName:@"Event"
                iconData:(NSData *)nil
                priority:0
                isSticky:NO
            clickContext:nil
              identifier:description];
}

- (NSDictionary*) registrationDictionaryForGrowl {
  NSString* path = [[NSBundle mainBundle] pathForResource: @"Growl Registration Ticket" ofType: @"growlRegDict"];
  NSDictionary* dictionary = [NSDictionary dictionaryWithContentsOfFile: path];
  return dictionary;
}
@end
