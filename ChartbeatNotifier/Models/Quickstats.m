//
//  Quickstats.m
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/21/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import "Quickstats.h"
#import "Account.h"
#import "Defines.h"

/** How often to update the site stats (seconds) */
NSTimeInterval const kRequestInterval = 3;

/** Timeout for site stats request (seconds) */
NSTimeInterval const kRequestTimeoutInterval = 2;

@implementation Quickstats

@synthesize parser = _parser;
@synthesize timer = _timer;
@synthesize receivedData = _receivedData;
@synthesize visits = _visits;
@synthesize formattedVisits = _formattedVisits;

+ (Quickstats *)sharedInstance {
    static Quickstats *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Quickstats alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _receivedData = [NSMutableData data];
    _parser = [[SBJsonParser alloc] init];
    
    return self;
}

- (void)startUpdating {
    [self updateCounter:nil];
    _timer = [NSTimer scheduledTimerWithTimeInterval:kRequestInterval
                                              target:self selector:@selector(updateCounter:)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)stopUpdating {
    [_timer invalidate];
    _timer = nil;
}

/** called by the timer when the stats counter needs to get updated */
- (void)updateCounter:(NSTimer *)aTimer
{
//    NSLog(@"updateCounter()");
    [self getSiteStats];
}

/** Initiate getting fresh site stats from the backend */
- (void)getSiteStats
{
//    NSLog(@"getSiteStats()");
    
    Account *sharedAccount = [Account sharedInstance];
    NSString *url = [NSMutableString stringWithFormat:kSiteStatsFormat, sharedAccount.apiKey, sharedAccount.domain];
    
    // TODO: don't kick off if previous load is still running
    // TODO: display errors to user
    [self loadRequest:url];
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
    
    [self setAttributes:json_string];
}

- (void)setAttributes:(NSString *)aJsonString {
    NSDictionary *data = [_parser objectWithString:aJsonString error:nil];
    self.visits = [data objectForKey:@"visits"];
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    self.formattedVisits = [numberFormatter stringFromNumber:self.visits];
}



@end
