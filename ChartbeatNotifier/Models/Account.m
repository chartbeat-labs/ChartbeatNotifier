//
//  Account.m
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/21/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import "Account.h"

/** Preference key for API Key */
NSString *const kPrefApiKey = @"apiKey";

/** Preference key for Domain */
NSString *const kPrefDomain = @"domain";

@implementation Account

@synthesize apiKey = _apiKey;
@synthesize domain = _domain;

+ (Account *) sharedInstance {
    static Account *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Account alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:kPrefApiKey];
    self.domain = [[NSUserDefaults standardUserDefaults] stringForKey:kPrefDomain];
    
    return self;
}

- (void)setApiKey:(NSString *)apiKey {
    _apiKey = apiKey;
    [[NSUserDefaults standardUserDefaults] setValue:apiKey forKey:kPrefApiKey];
    
}

- (void)setDomain:(NSString *)domain {
    _domain = domain;
    [[NSUserDefaults standardUserDefaults] setValue:domain forKey:kPrefDomain];
}

- (BOOL)isLoggedIn {
    return _apiKey != nil && _domain != nil;
}

@end
