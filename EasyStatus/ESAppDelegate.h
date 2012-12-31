//
//  CMAppDelegate.h
//  ConnectionMonitor
//
//  Created by Starke Michael on 26.02.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ESSettingsController;
@class ESLogController;

@interface ESAppDelegate : NSObject <NSApplicationDelegate>

#pragma mark properties
@property (strong,readonly) ESSettingsController *settingsController;
@property (strong,readonly) ESLogController *logController;
@property (assign) IBOutlet NSWindow *window;

#pragma mark actions
- (IBAction)showPreferences:(id)sender;
- (void)showLog;
@end
