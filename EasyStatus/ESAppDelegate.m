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

@interface ESAppDelegate ()

@property (strong) ESSettingsController *settingsController;
@property (strong) ESMenuController *menuController;

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

#pragma mark Actions
- (IBAction)showPreferences:(id)sender {
  if(self.settingsController == nil) {
    self.settingsController = [[ESSettingsController alloc] initWithWindowNibName:@"ESSettingsController"];
  }
  [self.settingsController showSettings];
}

- (IBAction)restartRouter:(id)sender {
  [[ESConnectionDaemon defaultDaemon] restartRouter];
}
@end
