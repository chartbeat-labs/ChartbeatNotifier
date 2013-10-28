//
//  PreferencesWindowController.m
//  ChartbeatNotifier
//
//  Created by Harry Wolff on 5/23/13.
//  Copyright (c) 2013 Betaworks. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "Account.h"
#import "Quickstats.h"

@implementation PreferencesWindowController

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
    
    Account *sharedAccount = [Account sharedInstance];
    [self.fieldApiKey setStringValue:sharedAccount.apiKey];
    [self.fieldDomain setStringValue:sharedAccount.domain];
    
    [self.displayedAttributePopUpButton selectItemAtIndex:sharedAccount.displayedAttributeIndex];
    
//    NSView *initialView = sharedAccount.isLoggedIn ? _loggedInView : _loggedOutView;
    [self resizeWindowForView:_loggedInView];
    self.window.contentView = _loggedInView;
    
    [self setBindings];
}

- (void)setBindings {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidEndEditing:) name:NSControlTextDidEndEditingNotification object:nil];
}

- (void)setAccountSettings {
    [[Account sharedInstance] setApiKey:[self.fieldApiKey stringValue]];
    [[Account sharedInstance] setDomain:[self.fieldDomain stringValue]];
    NSString *displayedAttribute = nil;
    NSInteger displayedAttributedIndex = [self.displayedAttributePopUpButton indexOfSelectedItem];
    switch (displayedAttributedIndex) {
        case 0:
            displayedAttribute = @"formattedVisits";
            break;
        case 1:
            displayedAttribute = @"formattedEngagedtime";
            break;
        default:
            break;
    }
    [[Account sharedInstance] setDisplayedAttribute:displayedAttribute];
    [[Account sharedInstance] setDisplayedAttributeIndex:displayedAttributedIndex];
}

- (void)windowWillClose:(NSNotification *)notification {
//    NSLog(@"windowWillClose()");
    [self setAccountSettings];
}

// TODO: there's a bug here, that it's not resizing subsequent views correctly. fix it.
- (void)resizeWindowForView:(NSView *) newView {    
    NSSize size = newView.frame.size;
    NSRect windowFrame = [self.window contentRectForFrameRect:self.window.frame];
    NSRect newWindowFrame = [self.window frameRectForContentRect:
                             NSMakeRect( NSMinX( windowFrame ), NSMaxY( windowFrame ) - size.height, size.width, size.height )];
    [self.window setFrame:newWindowFrame display:YES animate:[self.window isVisible]];
//    NSLog(@"    size: %@", NSStringFromSize(size));
//    NSLog(@" loggedIn: %@", NSStringFromRect(_loggedInView.frame));
//    NSLog(@"loggedOut: %@", NSStringFromRect(_loggedOutView.frame));
//    NSLog(@"-----");
}


- (IBAction)signIn:(id)sender {
//    NSLog(@"email value: %@", _emailTextField.stringValue);
//    NSLog(@"password value: %@", _passwordTextField.stringValue);
    
    NSView *initialView = YES ? _loggedInView : _loggedOutView;
    [self resizeWindowForView:initialView];
    self.window.contentView = initialView;
}

- (IBAction)openApiKeyWebpage:(id)sender {
    NSString *url = @"https://chartbeat.com/apikeys/";
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (IBAction)updatePreferences:(id)sender {
    [self setAccountSettings];
    [[Quickstats sharedInstance] resetUpdating];
}

#pragma mark -
#pragma mark Text field methods

- (void)textDidEndEditing:(NSNotification *)notification {
    [self setAccountSettings];
    [[Quickstats sharedInstance] resetUpdating];
}


@end
