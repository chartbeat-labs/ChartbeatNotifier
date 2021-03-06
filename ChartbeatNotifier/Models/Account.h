//
//  Account.h
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/21/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject

@property (nonatomic) NSString *domain;
@property (nonatomic) NSString *apiKey;

@property (nonatomic) NSString *displayedAttribute;
@property (nonatomic, assign) NSInteger displayedAttributeIndex;

+ (Account *) sharedInstance;

- (BOOL)isLoggedIn;

@end
