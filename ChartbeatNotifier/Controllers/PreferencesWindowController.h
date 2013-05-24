//
//  PreferencesWindowController.h
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/23/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController

@property (unsafe_unretained) IBOutlet NSTextField *fieldApiKey;
@property (unsafe_unretained) IBOutlet NSTextField *fieldDomain;

@end
