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

@end

@implementation ESMenuController

- (id)init {
  self = [super init];
  if (self) {
    NSArray *topLevelObjects = nil;
    [[NSBundle mainBundle] loadNibNamed:@"Menu" owner:self topLevelObjects:&topLevelObjects];
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    self.statusBarItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    NSImage *menuIconImage = [NSImage imageNamed:NSImageNameActionTemplate];
    [self.statusBarItem setImage:menuIconImage];
    [self.statusBarItem setEnabled:YES];
    [self.statusBarItem setHighlightMode:YES];
    [self.statusBarItem setMenu:self.menu];
  }
  return self;
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
@end
