//
//  CMAppDelegate.h
//  ConnectionMonitor
//
//  Created by Starke Michael on 26.02.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ESSettingsController;

@interface ESAppDelegate : NSObject <NSApplicationDelegate>

#pragma mark properties
@property (strong,readonly) ESSettingsController *settingsController;
@property (assign) IBOutlet NSWindow *window;

#pragma mark actions
- (IBAction)showPreferences:(id)sender;
- (IBAction)restartRouter:(id)sender;
@end
