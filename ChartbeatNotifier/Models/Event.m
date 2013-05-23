//
//  Events.m
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/22/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import "Event.h"
#import "Account.h"

/** URL for events for a given domain */
NSString *const kEventsFormat = @"http://chartbeat.com/event_api/events?apikey=%@&host=%@&minutes_ago=%i";

int const kMinutesAgo = 5;

@implementation Event

@synthesize value = _value;
@synthesize title = _title;
@synthesize type = _type;

-(id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    _value = [attributes valueForKeyPath:@"value"];
    _title = [attributes valueForKeyPath:@"title"];
    _type = [attributes valueForKeyPath:@"type"];
    return self;
}

+ (void)getNewEvents:(int)minutesAgo withBlock:(void (^)(NSArray *, NSError *))block {
    if (!minutesAgo) {
        minutesAgo = kMinutesAgo;
    }
    Account *sharedAccount = [Account sharedInstance];
    NSString *url = [NSMutableString stringWithFormat:kEventsFormat, sharedAccount.apiKey, sharedAccount.domain, minutesAgo];
    [self asyncRequest:[self urlRequestWithUrl:url]
               success:^(NSDictionary *json, NSURLResponse *response) {
                   NSArray *eventsFromResponse = [json valueForKeyPath:@"data.events"];
                   NSMutableArray *mutableEvents = [NSMutableArray arrayWithCapacity:[eventsFromResponse count]];
                   for (NSDictionary *attributes in eventsFromResponse) {
                       Event *event = [[Event alloc] initWithAttributes:attributes];
                       [mutableEvents addObject:event];
                   }
                   
                   if (block) {
                       block([NSArray arrayWithArray:mutableEvents], nil);
                   }

               }
               failure:^(NSData *data, NSError *error) {
                   NSLog(@"Failed to load");
                   block(nil, error);
               }
     ];
  
    
}

@end
