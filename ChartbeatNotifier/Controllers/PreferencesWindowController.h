//
//  PreferencesWindowController.h
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/23/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesWindowController : NSWindowController <NSWindowDelegate>

@property (strong) IBOutlet NSView *loggedOutView;
@property (unsafe_unretained) IBOutlet NSTextField *emailTextField;
@property (unsafe_unretained) IBOutlet NSSecureTextField *passwordTextField;
- (IBAction)signIn:(id)sender;



@property (strong) IBOutlet NSView *loggedInView;
@property (unsafe_unretained) IBOutlet NSTextField *fieldApiKey;
@property (unsafe_unretained) IBOutlet NSTextField *fieldDomain;
- (IBAction)openApiKeyWebpage:(id)sender;
- (IBAction)updatePreferences:(id)sender;


@end
