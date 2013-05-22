//
//  APIClient.h
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/22/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIClient : NSObject

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

/** Class method to make a request with a block */
+ (void)asyncRequest:(NSURLRequest *)request
             success:(void(^)(NSDictionary *json, NSURLResponse *response))successBlock_
             failure:(void(^)(NSData *data, NSError *error))failureBlock_;

+ (NSURLRequest *)urlRequestWithUrl:(NSString *)urlString;

+ (NSDictionary *)parseData:(NSData *)data;

@end
