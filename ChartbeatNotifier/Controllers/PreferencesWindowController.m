//
//  PreferencesWindowController.m
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/23/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "Account.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController

@synthesize fieldDomain = _fieldDomain;
@synthesize fieldApiKey = _fieldApiKey;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    Account *sharedAccount = [Account sharedInstance];
    [self.fieldApiKey setStringValue:sharedAccount.apiKey];
    [self.fieldDomain setStringValue:sharedAccount.domain];
}

// only used for Preferences Window
// TODO: abstract into own controller
- (void)windowWillClose:(NSNotification *)notification {
    NSLog(@"windowWillClose()");
    [[Account sharedInstance] setApiKey:[self.fieldApiKey stringValue]];
    [[Account sharedInstance] setDomain:[self.fieldDomain stringValue]];
}

@end
