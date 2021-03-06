//
//  Events.h
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/22/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIClient.h"

@interface Event : APIClient

@property NSString *title;
@property NSString *value;
@property NSString *type;


- (id)initWithAttributes:(NSDictionary *)attributes;

+ (void)getNewEvents:(int)minutesAgo withBlock:(void (^)(NSArray *events, NSError *error))block;

@end
