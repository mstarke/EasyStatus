//
//  ESStatusDaemon.m
//  EasyStatus
//
//  Created by Michael Starke on 14.10.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "ESStatusDaemon.h"
#import "ESSettingsKeys.h"
#import "ESConnectionDataDelegate.h"

NSString *const ESStatusUpdatedNotification = @"ESStatusUpdatedNotification";
NSString *const kESSignalStrengthKey = @"kESSignalStrengthKey";
NSString *const kESConnectionStatusKey = @"kESConnectionStatusKey";
NSTimeInterval kESRequestTimeout = 10.0;

/*
 Private constants
 */
NSString *const kESLoginUrl = @"http://easy.box/cgi-bin/login.exe?user=%@&pws=%@";
NSString *const kESStatusUrl = @"http://easy.box/status_main.stm";
NSString *const kSignalPercentNeedle = @"var signalPercent=";

@interface ESStatusDaemon () {
  NSString *statusSource;
  NSString *loginSource;
  BOOL isAuthenticated;
}

@property (strong) NSMutableData *loginData;
@property (strong) NSMutableData *statusData;
@property (strong) NSTimer *updateTimer;
@property (strong) ESConnectionDataDelegate *loginDelegate;
@property (strong) ESConnectionDataDelegate *statusDelegate;

- (void)timer:(NSTimer *)timer;
- (void)requestStatus;
- (void)updateStatus;
- (void)login;

@end

@implementation ESStatusDaemon


- (id)init {
  self = [super init];
  if (self) {
    isAuthenticated = NO;
    self.loginDelegate = [[ESConnectionDataDelegate alloc] init];
    self.statusDelegate = [[ESConnectionDataDelegate alloc] init];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
  }
  return self;
}

- (void)dealloc {
  [_updateTimer invalidate];
}

- (void)timer:(NSTimer *)timer {
  if(_updateTimer != timer) {
    return; // wrong timer
  }
  [self requestStatus];
}

- (void)login {
  NSString *login;// = [userDefaults stringForKey:kESSettingsKeyLogin];
  NSString *password;// = [userDefaults stringForKey:kESSettingsKeyPassword];
  
  NSString *loginUrlString = [NSString stringWithFormat:kESLoginUrl, login, password];
  NSURL *loginUrl = [NSURL URLWithString:loginUrlString];
  NSURLRequest *loginRequest=[NSURLRequest requestWithURL:loginUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kESRequestTimeout];
  NSURLConnection *loginConnection = [NSURLConnection connectionWithRequest:loginRequest delegate:self.loginDelegate];
  [loginConnection start];
}

- (void)requestStatus {
  NSURL *statusUrl = [NSURL URLWithString:kESStatusUrl];
  NSURLRequest *statusRequest=[NSURLRequest requestWithURL:statusUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kESRequestTimeout];
  NSURLConnection *statusConnection = [NSURLConnection connectionWithRequest:statusRequest delegate:self.statusDelegate];
  [statusConnection start];
}

- (void)updateStatus {
  
//  hitRange = [statusSource rangeOfString:kSignalPercentNeedle options:NSCaseInsensitiveSearch];
//  NSString *signalStrengthString = [statusSource substringWithRange:NSMakeRange(hitRange.location + hitRange.length, 4)];
//  NSLog(@"Signal Strenght: %@", signalStrengthString);
//  NSScanner *scanner = [NSScanner scannerWithString:signalStrengthString];
//  NSInteger signalePercent;
//  [scanner scanInteger:&signalePercent];
//  NSLog(@"Signal: %ld", signalePercent);
  
}

@end
