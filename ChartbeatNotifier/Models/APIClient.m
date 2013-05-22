//
//  APIClient.m
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/22/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import "APIClient.h"
#import <SBJson/SBJson.h>

/** How often to update the site stats (seconds) */
NSTimeInterval const kRequestInterval = 3;

/** Timeout for site stats request (seconds) */
NSTimeInterval const kRequestTimeoutInterval = 2;

@implementation APIClient

@synthesize receivedData = _receivedData;
@synthesize timer = _timer;
@synthesize requestInterval = _requestInterval;

/** from https://github.com/rickerbh/NSURLConnection-Blocks */
+ (void)asyncRequest:(NSURLRequest *)request
             success:(void(^)(NSDictionary *json, NSURLResponse *response))successBlock_
             failure:(void(^)(NSData *data, NSError *error))failureBlock_ {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSURLResponse *response = nil;
		NSError *error = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
        
		if (error) {
			failureBlock_(data,error);
		} else {
            NSDictionary *json = [self parseData:data];
			successBlock_(json,response);
		}
        
	});
}

+ (NSURLRequest *)urlRequestWithUrl:(NSString *)urlString {
    NSURLRequest *theRequest;
    theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                              timeoutInterval:kRequestTimeoutInterval];
    return theRequest;
}

+ (NSDictionary *)parseData:(NSData *)data {
    NSString *json_string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *parsedData = [parser objectWithString:json_string error:nil];
    return parsedData;
}



- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _receivedData = [NSMutableData data];
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

- (void)loadRequest:(NSString *)aURL
{
    //    NSLog(@"loadRequest: %@", aURL);
    
    NSURLConnection *theConnection;
    theConnection = [[NSURLConnection alloc] initWithRequest:[APIClient urlRequestWithUrl:aURL]
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
    NSDictionary *data = [APIClient parseData:_receivedData];
    [_receivedData setLength:0];
    [self setAttributes:data];
}

/** Override to update model with new values */
- (void)setAttributes:(NSDictionary *)json {
    NSLog(@"setAttributes(%@)", json);
}


@end
