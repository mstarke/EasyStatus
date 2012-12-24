//
//  ESCredentialManager.m
//  EasyStatus
//
//  Created by Michael Starke on 24.12.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "ESCredentialManager.h"
#import "SSKeychain.h"

NSString *const kESCredentialManagerEasyStatusServiceName = @"EasySettings Login";
NSString *const kESCredentialManagerPasswordKey = @"kESCredentialManagerPasswordKey";
NSString *const kESCredentialManagerLoginKey = @"kESCredentialManagerLoginKey";

@interface ESCredentialManager ()

- (NSDictionary *)credentials;

@end

@implementation ESCredentialManager

+ (ESCredentialManager *)defaultManager {
  static ESCredentialManager *sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[ESCredentialManager alloc] init];
  });
  return sharedInstance;
}

- (NSDictionary *)credentials {
  NSString *password = @"";
  NSString *login = @"";
  NSArray *accounts = [SSKeychain accountsForService:kESCredentialManagerEasyStatusServiceName];
  if(nil != accounts ) {
    login = [accounts lastObject][kSSKeychainAccountKey];
    if([accounts count] > 1) {
      NSLog(@"Warning, multiple entries found. Cleaning up");
      NSRange unusedRange = NSMakeRange(0, [accounts count] - 1);
      NSArray *unusedAccounts = [accounts subarrayWithRange:unusedRange];
      for(NSDictionary *unusedAccount in unusedAccounts) {
        [SSKeychain deletePasswordForService:kESCredentialManagerEasyStatusServiceName account:unusedAccount[kSSKeychainAccountKey]];
      }
    }
    NSError *passwordError = nil;
    password = [SSKeychain passwordForService:kESCredentialManagerEasyStatusServiceName account:login error:&passwordError];
  }
  if(password == nil) {
    password = @"";
  }
  if(login == nil) {
    login = @"";
  }
  return @{ kESCredentialManagerPasswordKey: password, kESCredentialManagerLoginKey: login };
}

- (void)updateLogin:(NSString *)login password:(NSString *)password {
  if([login length] == 0 || [password length] == 0) {
    NSLog(@"Login and/or password missing. Aborting.");
    return; // Login not set, canceling
  }
  NSError *error = nil;
  NSArray *accountArray = [SSKeychain accountsForService:kESCredentialManagerEasyStatusServiceName error:&error];
  if(accountArray != nil) {
    for(NSDictionary *accountDictionary in accountArray) {
      // Only delete the accounts that do not match the current account name
      // this prevents deletion and recreation on password changes
      if( NO == [accountDictionary[kSSKeychainAccountKey] isEqualToString:login] ) {
        [SSKeychain deletePasswordForService:kESCredentialManagerEasyStatusServiceName account:accountDictionary[kSSKeychainAccountKey]];
      }
    }
  }
  BOOL success = [SSKeychain setPassword:password forService:kESCredentialManagerEasyStatusServiceName account:login error:&error];
  if(NO == success) {
    NSLog(@"Error while trying to set password for login %@: %@", login, [error localizedDescription]);
  }
  else {
    // notify of changes
  }
}

#pragma mark properties
- (NSString *)password {
  @synchronized(self) {
    return [self credentials][kESCredentialManagerPasswordKey];
  }
}

- (NSString *)login {
  @synchronized(self) {
    return [self credentials][kESCredentialManagerLoginKey];
  }
}

@end
