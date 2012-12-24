//
//  CMSettingsController.m
//  ConnectionMonitor
//
//  Created by Michael Starke on 16.09.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "ESSettingsController.h"
#import "ESCredentialManager.h"

@interface ESSettingsController ()

@property (weak) IBOutlet NSTextField *loginTextfield;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;

@end

@implementation ESSettingsController

- (id)initWithWindow:(NSWindow *)window {
  self = [super initWithWindow:window];
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
}

#pragma mark NSWindow Delegate
- (void)windowWillClose:(NSNotification *)notification {
  NSString *password = [self.passwordTextField stringValue];
  NSString *login = [self.loginTextfield stringValue];
  [[ESCredentialManager defaultManager] updateLogin:login password:password];
}

- (void)showSettings {
  ESCredentialManager *defaultManager = [ESCredentialManager defaultManager];
  [self.loginTextfield setStringValue:defaultManager.login];
  [self.passwordTextField setStringValue:defaultManager.password];
  [self showWindow:self.window];
}

@end
