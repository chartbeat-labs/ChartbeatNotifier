//
//  Notifier.m
//  ChartbeatNotifier
//
//  Created by Tom Germeau on 6/7/12.
//  Copyright (c) 2012 Betaworks. All rights reserved.
//

#import "Notifier.h"
#import "MAAttachedWindow.h"


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
//  self = [super initWithNibName:@"PopupVuew" bundle:[NSBundle bundleForClass:[Notifier class]]];    
  growlAvailable = false;
//  [self loadGrowl];
  return self;
}

- (void)setStatusItem:(NSStatusItem*) item {
  statusItem = item;
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
    [self moo:title:description];
  } else {
    [self growl:title:description];
  }
}

- (NSDictionary*) registrationDictionaryForGrowl {
  NSString* path = [[NSBundle mainBundle] pathForResource: @"Growl Registration Ticket" ofType: @"growlRegDict"];
  NSDictionary* dictionary = [NSDictionary dictionaryWithContentsOfFile: path];
  return dictionary;
}

- (void)growl:(NSString *)title: (NSString *)description
{
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

- (void)moo:(NSString *)title: (NSString *)description
{
  NSRect frame = [[statusItem valueForKey:@"window"] frame];
  
//  NSRect frame = [[statusItem view] frame];
//  NSRect frame = [[[statusItem view] window] frame];
  NSPoint p = NSMakePoint(NSMidX(frame), NSMinY(frame));
//  NSPoint p = NSMakePoint(1000, 900);
  NSView *v = [[NSView alloc] initWithFrame:NSMakeRect(0,0,300,80)];
  NSTextField *text = [[NSTextField alloc] initWithFrame:NSMakeRect(10,10,280,60)];
  [text setSelectable:false];
  [text setBackgroundColor:[NSColor clearColor]];
  [text setTextColor:[NSColor whiteColor]];
  [text setBordered:false];
//  NSTextContainer *container = [[NSTextContainer alloc] init];

  [text setStringValue:[NSString stringWithFormat:@"%@\n%@", title, description]];
  [v addSubview:text];
  attachedWindow = [[MAAttachedWindow alloc] initWithView:v 
                                          attachedToPoint:p 
                                                 inWindow:nil 
                                                   onSide:MAPositionBottom 
                                               atDistance:5.0];
//  [textField setTextColor:[attachedWindow borderColor]];
  //        [textField setStringValue:@"Your text goes here..."];
  [attachedWindow setArrowHeight:8];
  [attachedWindow setArrowBaseWidth:16];
  [attachedWindow makeKeyAndOrderFront:self];
}

//
//  [attachedWindow orderOut:self];
//  [attachedWindow release];
//  attachedWindow = nil; 
@end
