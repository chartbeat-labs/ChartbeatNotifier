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

/** Preference key for Displayed Attribute */
NSString *const kPrefDisplayedAttribute = @"displayedAttribute";

NSString *const kPrefDisplayedAttributeIndex = @"displayedAttributeIndex";

@implementation Account

@synthesize apiKey = _apiKey;
@synthesize domain = _domain;

@synthesize displayedAttribute = _displayedAttribute;

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
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self.apiKey = [standardUserDefaults stringForKey:kPrefApiKey];
    self.domain = [standardUserDefaults stringForKey:kPrefDomain];
    self.displayedAttribute = [standardUserDefaults stringForKey:kPrefDisplayedAttribute];
    self.displayedAttributeIndex = [standardUserDefaults integerForKey:kPrefDisplayedAttributeIndex];
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

- (void)setDisplayedAttribute:(NSString *)displayedAttribute {
    _displayedAttribute = displayedAttribute;
    [[NSUserDefaults standardUserDefaults] setValue:displayedAttribute forKey:kPrefDisplayedAttribute];
}

- (void)setDisplayedAttributeIndex:(NSInteger)displayedAttributeIndex {
    _displayedAttributeIndex = displayedAttributeIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:displayedAttributeIndex forKey:kPrefDisplayedAttributeIndex];
}

- (BOOL)isLoggedIn {
    return _apiKey != nil && _domain != nil;
}

@end
