//
//  ESMenuController.m
//  EasyStatus
//
//  Created by Michael Starke on 24.12.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "ESMenuController.h"
#import "ESAppDelegate.h"
#import "ESSettingsController.h"
#import "ESConnectionDaemon.h"

@interface ESMenuController ()

@property (strong) IBOutlet NSMenu *menu;
@property (weak) IBOutlet NSMenuItem *statusItem;
@property (weak) IBOutlet NSMenuItem *preferencesItem;
@property (weak) IBOutlet NSMenuItem *restartItem;
@property (weak) IBOutlet NSMenuItem *quitItem;
@property (weak) IBOutlet NSMenuItem *logItem;
@property (strong) NSStatusItem *statusBarItem;


- (IBAction)quit:(id)sender;
- (IBAction)restart:(id)sender;
- (IBAction)preferences:(id)sender;
- (IBAction)log:(id)sender;

- (void)didChangeStatus:(NSNotification *)notification;

@end

@implementation ESMenuController

- (id)init {
  self = [super init];
  if (self) {
    NSArray *topLevelObjects = nil;
    [[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self topLevelObjects:&topLevelObjects];
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    self.statusBarItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [self.statusBarItem setImage:[[NSBundle mainBundle] imageForResource:@"StatusUnknown"]];
    [self.statusBarItem setEnabled:YES];
    [self.statusBarItem setHighlightMode:YES];
    [self.statusBarItem setMenu:self.menu];
    [self.restartItem setEnabled:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatus:) name:ESConnectionDaemonStatusUpdateNotification object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction)log:(id)sender {
  ESAppDelegate *delegate = [NSApp delegate];
  [delegate showLog];
}

- (IBAction)quit:(id)sender {
  [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)restart:(id)sender {
}

- (IBAction)preferences:(id)sender {
  ESAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
  [appDelegate showPreferences:self];
}

- (void)didChangeStatus:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    ESConnectionStatus status = [userInfo[ESConnectionDaemonConnectionStatusKey] intValue];
    NSInteger signalStrength = [userInfo[ESConnectionDaemonSignalStrengthKey] integerValue];
    //NSNumber *signalStrength = userInfo[ESConnectionThreadSignalStrengthKey];
    NSString *imageName;
    NSString *statusString;
    switch (status) {
      case ESConnectionStatusConnectionOffline:
        imageName = @"Offline";
        statusString = @"Offline";
        break;
      case ESConnectioNStatusConnectionOnline:
        imageName = @"ConnectionOK";
        statusString = [NSString stringWithFormat:@"Online (%li%%)", signalStrength ];
        break;
      case ESConnectionStatusRouterUnreachable:
      default:
        statusString = @"Router nicht erreichbar";
        imageName = @"Offline";
        break;
    }
    NSImage *statusImage = [[NSBundle mainBundle] imageForResource:imageName];
    [self.statusBarItem setImage:statusImage];
    [self.statusItem setTitle:statusString];
    [self.restartItem setEnabled:status != ESConnectionStatusRouterUnreachable ];
}

@end
