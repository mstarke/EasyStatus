//
//  CMSettingsController.m
//  ConnectionMonitor
//
//  Created by Michael Starke on 16.09.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "ESSettingsController.h"
#import "ESSettingsKeys.h"

@interface ESSettingsController ()

@property (weak) IBOutlet NSTextField *userNameTextfield;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;

@end

@implementation ESSettingsController
@synthesize userNameTextfield;
@synthesize passwordTextField;

- (id)initWithWindow:(NSWindow *)window {
  self = [super initWithWindow:window];
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
  //NSString *passwordString;
  [self.userNameTextfield bind:@"value" toObject:defaultsController withKeyPath:[NSString stringWithFormat:@"values.%@", kESSettingsKeyLogin] options:nil];
  [self.passwordTextField bind:@"value" toObject:defaultsController withKeyPath:[NSString stringWithFormat:@"values.%@", kESSettingsKeyPassword] options:nil];
}

- (void)showSettings {
  [self showWindow:self.window];
}

@end
