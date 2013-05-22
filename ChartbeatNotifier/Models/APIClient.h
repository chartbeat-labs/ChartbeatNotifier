//
//  APIClient.h
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/22/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SBJson/SBJson.h>

@interface APIClient : NSObject

/** JSON parser used to part API results */
@property (nonatomic) SBJsonParser *parser;

/** Used to receive backend data */
@property (nonatomic) NSMutableData *receivedData;

/** Timer used to periodically update the counter */
@property (nonatomic) NSTimer *timer;

/** Request interval to poll for updates */
@property (nonatomic) NSTimeInterval requestInterval;

- (void)startUpdating;
- (void)stopUpdating;

- (void)loadRequest:(NSString *)aURL;

/** Method to override when request is done to update values */
- (void)setAttributes:(NSDictionary *)json;

@end
