//
//  Quickstats.h
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/21/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SBJson/SBJson.h>

@interface Quickstats : NSObject

/** JSON parser used to part API results */
@property (nonatomic) SBJsonParser *parser;

/** Timer used to periodically update the counter */
@property (nonatomic) NSTimer *timer;

/** Used to receive backend data */
@property (nonatomic) NSMutableData *receivedData;

@property (nonatomic) NSNumber *visits;
@property (nonatomic) NSString *formattedVisits;

+ (Quickstats *)sharedInstance;

- (void)startUpdating;
- (void)stopUpdating;

@end
