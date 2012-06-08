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
//@synthesize webView;
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

//this returns a nice name for the method in the JavaScript environment
+(NSString*)webScriptNameForSelector:(SEL)sel
{
  if(sel == @selector(logJavaScriptString:))
    return @"notify";
  return nil;
}

//this allows JavaScript to call the -logJavaScriptString: method
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)sel
{
  if(sel == @selector(logJavaScriptString:))
    return NO;
  return YES;
}

//called when the nib objects are available, so do initial setup
- (void)awakeFromNib
{
  [webView setFrameLoadDelegate:self];
}


//this is a simple log command
- (void)logJavaScriptString:(NSString*) logText
{
  NSLog(@"HI: %@",logText);
  [[Notifier getSingleton] notify:[NSString stringWithFormat:@"%@", logText]];
  [statusItem setTitle:[NSString stringWithFormat:@"%@", logText]];
}

//this is called as soon as the script environment is ready in the webview
- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowScriptObject forFrame:(WebFrame *)frame
{
  [windowScriptObject setValue:self forKey:@"chartbeatNative"];
}
@end
