//
//  Quickstats.h
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/21/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIClient.h"

@interface Quickstats : APIClient

@property (nonatomic) NSNumber *visits;
@property (nonatomic) NSString *formattedVisits;
@property (nonatomic) NSNumber *engagedTime;
@property (nonatomic) NSString *formattedEngagedtime;

+ (Quickstats *)sharedInstance;

@end
