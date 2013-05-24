//
//  Quickstats.m
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/21/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import "Quickstats.h"
#import "Account.h"

/** URL for site stats for a given domain */
NSString *const kSiteStatsFormat = @"http://api.chartbeat.com/live/quickstats?apikey=%@&host=%@";

@implementation Quickstats

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
    
    return self;
}

- (void)startUpdating {
    [super startUpdating];
    [self getSiteStats];
}


-(void)resetUpdating {
    self.formattedVisits = @"Loading";
    [super resetUpdating];
}

/** called by the timer when the stats counter needs to get updated */
- (void)update:(NSTimer *)aTimer
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


- (void)setAttributes:(NSDictionary *)json {
    self.visits = [json objectForKey:@"visits"];
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    self.formattedVisits = [numberFormatter stringFromNumber:self.visits];
}



@end
