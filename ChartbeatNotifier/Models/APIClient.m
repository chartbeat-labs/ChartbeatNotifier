//
//  APIClient.m
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/22/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import "APIClient.h"

/** How often to update the site stats (seconds) */
NSTimeInterval const kRequestInterval = 3;

/** Timeout for site stats request (seconds) */
NSTimeInterval const kRequestTimeoutInterval = 2;

@implementation APIClient

@synthesize parser = _parser;
@synthesize receivedData = _receivedData;
@synthesize timer = _timer;
@synthesize requestInterval = _requestInterval;

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _receivedData = [NSMutableData data];
    _parser = [[SBJsonParser alloc] init];
    _requestInterval = kRequestInterval;
    
    return self;
}

- (void)startUpdating {
    _timer = [NSTimer scheduledTimerWithTimeInterval:self.requestInterval
                                              target:self selector:@selector(update:)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)stopUpdating {
    [_timer invalidate];
    _timer = nil;
}

/** Called by timer, override to perform work */
- (void)update:(NSTimer *)timer {
    NSLog(@"update(%@)", timer);
}

#pragma mark -
#pragma mark Request Handling
// TODO: move all this to a separate class

- (void)loadRequest:(NSString *)aURL
{
    //    NSLog(@"loadRequest: %@", aURL);
    
    NSURLRequest *theRequest;
    theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:aURL]
                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                              timeoutInterval:kRequestTimeoutInterval];
    
    // TODO: who owns this?
    NSURLConnection *theConnection;
    theConnection = [[NSURLConnection alloc] initWithRequest:theRequest
                                                    delegate:self];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    //    NSLog(@"didReceiveResponse()");
    
    [_receivedData setLength:0];
    
    if (![response isKindOfClass: [NSHTTPURLResponse class]]) {
        return;
    }
    
    int statusCode = (int)[(NSHTTPURLResponse*) response statusCode];
    if (statusCode != 200) {
        NSLog(@"Got non-200 response code: %d (%@)",
              statusCode,
              [response URL]);
        return;
    }
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //    NSLog(@"didReceiveData()");
    
    [_receivedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Request error: %@ (%@)",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    connection = nil;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //    NSLog(@"connectionDidFinishLoading()");
    
    connection = nil;
    
    NSString *json_string = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
    [_receivedData setLength:0];
    
    NSDictionary *data = [_parser objectWithString:json_string error:nil];
    [self setAttributes:data];
}

/** Override to update model with new values */
- (void)setAttributes:(NSDictionary *)json {
    NSLog(@"setAttributes(%@)", json);
}


@end
