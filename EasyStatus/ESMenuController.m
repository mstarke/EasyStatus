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
#import "ESConnectionThread.h"

@interface ESMenuController ()

@property (strong) IBOutlet NSMenu *menu;
@property (weak) IBOutlet NSMenuItem *statusItem;
@property (weak) IBOutlet NSMenuItem *preferencesItem;
@property (weak) IBOutlet NSMenuItem *restartItem;
@property (weak) IBOutlet NSMenuItem *quitItem;
@property (strong) NSStatusItem *statusBarItem;

- (IBAction)quit:(id)sender;
- (IBAction)restart:(id)sender;
- (IBAction)preferences:(id)sender;

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
    NSImage *menuIconImage = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
    [self.statusBarItem setImage:menuIconImage];
    [self.statusBarItem setEnabled:YES];
    [self.statusBarItem setHighlightMode:YES];
    [self.statusBarItem setMenu:self.menu];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatus:) name:ESConnectionThreadStatusUpdateNotification object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
  if(NO == [NSThread isMainThread]) {
    [self performSelectorOnMainThread:@selector(didChangeStatus:) withObject:notification waitUntilDone:NO];
  }
  else {
    NSDictionary *userInfo = [notification userInfo];
    ESConnectionStatus status = [userInfo[ESConnectionThreadConnectionStatusKey] intValue];
    //NSNumber *signalStrength = userInfo[ESConnectionThreadSignalStrengthKey];
    NSString *imageName;
    NSString *statusString;
    switch (status) {
      case ESConnectionStatusConnectionOffline:
        imageName = NSImageNameStatusUnavailable;
        statusString = @"Offline";
        break;
      case ESConnectioNStatusConnectionOnline:
        imageName = NSImageNameStatusAvailable;
        statusString = @"Online";
        break;
      case ESConnectionStatusRouterUnreachable:
      default:
        statusString = @"Router nicht erreichbar";
        imageName = NSImageNameStopProgressFreestandingTemplate;
        break;
    }
    NSSize imageSize = NSMakeSize(16, 16);
    NSImage *statusImage = [NSImage imageNamed:imageName];
    [statusImage setSize:imageSize];
    [self.statusBarItem setImage:statusImage];
    [self.statusItem setTitle:statusString];
  }
}

@end
