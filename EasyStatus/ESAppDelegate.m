//
//  CMAppDelegate.m
//  ConnectionMonitor
//
//  Created by Starke Michael on 26.02.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "ESAppDelegate.h"
#import "ESSettingsController.h"
#import "ESStatusDaemon.h"

@interface ESAppDelegate ()

@property (strong) NSMutableDictionary *dataDictionary;
@property (strong) ESSettingsController *settingsController;
@property (strong) NSMutableArray *connections;
@property (strong) ESStatusDaemon *statusDaemon;

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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  self.statusDaemon = [[ESStatusDaemon alloc] init];
}

#pragma mark Actions
- (IBAction)showPreferences:(id)sender {
  if(self.settingsController == nil) {
    self.settingsController = [[ESSettingsController alloc] initWithWindowNibName:@"ESSettingsController"];
  }
  [self.settingsController showSettings];
}
@end
