//
//  DataChannel.m
//  ChartbeatNotifier
//
//  Created by Tom Germeau on 6/8/12.
//  Copyright (c) 2012 Betaworks. All rights reserved.
//

#import "DataChannel.h"
#import "Defines.h"
#import "Notifier.h"

/** URL for the dashboard for a given domain */
NSString *const kDatachannelURLFormat = @"http://tomdev.local/dashboard/?url=%@&k=%@";

@implementation DataChannel

- (id)init
{
  self = [super init];
  webView = [[WebView alloc] init];
  return self;
}

- (void)load:(NSString *)aDomain apikey:(NSString *)aApiKey statusItem:(NSStatusItem *)aStatusItem
{  
  statusItem = aStatusItem;
  NSString *dashUrl = [NSMutableString stringWithFormat:kDatachannelURLFormat, aDomain, aApiKey];
  [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dashUrl]]];
  [webView setFrameLoadDelegate:self];

}

+(NSString*)webScriptNameForSelector:(SEL)sel
{
  if(sel == @selector(notifyJavaScriptString:))
    return @"notify";
  if(sel == @selector(setTextJavaScriptString:))
    return @"setText";
  return nil;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
  
  if(sel == @selector(notifyJavaScriptString:))
    return NO;
  if(sel == @selector(setTextJavaScriptString:))
    return NO;
  return YES;
}

//- (void)notifyJavaScriptString:(NSString*) aDescription title:(NSString*)aTitle
- (void)notifyJavaScriptString:(NSString*) aDescription
{
  NSLog(@"notifyJavaScriptString: %@",aDescription);
  [[Notifier getSingleton] notify:@"Notable page":[NSString stringWithFormat:@"%@", aDescription]];
}

- (void)setTextJavaScriptString:(NSString*) text
{
  NSLog(@"setTextJavaScriptString: %@",text);
  [statusItem setTitle:[NSString stringWithFormat:@"%@", text]];

}

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
{
  [windowScriptObject setValue:self forKey:@"chartbeatNative"];
}
@end
