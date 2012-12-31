//
//  CMAppDelegate.m
//  ConnectionMonitor
//
//  Created by Starke Michael on 26.02.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "ESAppDelegate.h"
#import "ESSettingsController.h"
#import "ESConnectionDaemon.h"
#import "ESMenuController.h"
#import "ESLogController.h"

@interface ESAppDelegate ()

@property (strong) ESSettingsController *settingsController;
@property (strong) ESMenuController *menuController;
@property (strong) ESLogController *logController;

@end

@implementation ESAppDelegate

/*
 Initialize Settings
 */
+ (void)initialize {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"Defaults" withExtension:@"plist"];
  NSDictionary *defaultPrefrences = [NSDictionary dictionaryWithContentsOfURL:fileUrl];
  [userDefaults registerDefaults:defaultPrefrences];
}

#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [[ESConnectionDaemon defaultDaemon] enableMonitoring];
  self.menuController = [[ESMenuController alloc] init];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
  [[ESConnectionDaemon defaultDaemon] cancelMonitoring];
}

#pragma mark Actions
- (IBAction)showPreferences:(id)sender {
  if(self.settingsController == nil) {
    self.settingsController = [[ESSettingsController alloc] initWithWindowNibName:@"ESSettingsController"];
  }
  [self.settingsController showSettings];
}

- (void)showLog {
  if(self.logController == nil) {
    self.logController = [[ESLogController alloc] initWithWindowNibName:@"LogWindow"];
  }
  [self.logController showWindow:self.logController.window];
  [self.logController.window makeKeyAndOrderFront:self.logController.window];
}

@end
