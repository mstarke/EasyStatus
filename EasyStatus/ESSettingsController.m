//
//  CMSettingsController.m
//  ConnectionMonitor
//
//  Created by Michael Starke on 16.09.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "ESSettingsController.h"
#import "ESSettingsKeys.h"
#import "SSKeychain.h"

@interface ESSettingsController ()

@property (weak) IBOutlet NSTextField *userNameTextfield;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
@property (strong) NSString *login;
@property (nonatomic, strong) NSString *password;


@end

@implementation ESSettingsController

- (id)initWithWindow:(NSWindow *)window {
  self = [super initWithWindow:window];
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  //NSString *passwordString;
  [self.userNameTextfield bind:@"value" toObject:self withKeyPath:@"login" options:nil];
  [self.passwordTextField bind:@"value" toObject:self withKeyPath:@"password" options:nil];
}

- (void)showSettings {
  [self showWindow:self.window];
}

#pragma mark Properties
- (void)setPassword:(NSString *)password {
  NSArray *accounts = [SSKeychain accountsForService:kEasyStatusServiceName];
  if(accounts != nil) {
    NSString *account = [accounts lastObject];
    BOOL success = [SSKeychain setPassword:password forService:kEasyStatusServiceName account:account];
    NSLog(@"Setting password %@", success ? @"succeeded" : @"failed");
  }
}

- (NSString *)password {
  NSString *password = nil;
  NSArray *accounts = [SSKeychain accountsForService:kEasyStatusServiceName];
  if(accounts != nil) {
    NSString *account = [accounts lastObject];
    password = [SSKeychain passwordForService:kEasyStatusServiceName account:account];
  }
  return password;
}

- (NSString *)login {
  NSArray *accounts = [SSKeychain accountsForService:kEasyStatusServiceName];
  if(accounts != nil) {
    return [accounts lastObject];
  }
  return nil;
}

- (void)setLogin:(NSString *)login {
  NSString *currentPassword = self.password;
  if(currentPassword == nil) {
    currentPassword = @"";
  }
  NSError *error = nil;
  [SSKeychain setPassword:currentPassword forService:kEasyStatusServiceName account:login error:&error];
  NSLog(@"%@", [error localizedDescription]);
}
@end
