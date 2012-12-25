//
//  ESConnectionThread.m
//  EasyStatus
//
//  Created by Michael Starke on 23.12.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "ESConnectionThread.h"
#import "ESCredentialManager.h"
#import "NSString+ESStringAdditions.h"

NSString *const ESConnectionThreadStatusUpdateNotification  = @"ESConnectionThreadStatusUpdateNotification";
NSString *const ESConnectionThreadSignalStrengthKey         = @"ESConnectionThreadSignalStrengthKey";
NSString *const ESConnectionThreadConnectionStatusKey       = @"ESConnectionThreadConnectionStatusKey";

/*
 Private constants
 */
NSString *const kESRouterURLString = @"http://easy.box";
NSString *const kESConnectionThreadLoginUrl = @"http://easy.box/cgi-bin/login.exe?user=%@&pws=%@";
NSString *const kESConnectionThreadStatusUrl = @"http://easy.box/status_main.stm";
NSString *const kESConnectionThreadLogOutUrl = @"http://easy.box/cgi-bin/logout.exe";
NSString *const kESConnectionThreadLoginSuccessNeedle = @"setupa_brief.stm";
NSTimeInterval kESConnectionThreadSleepInterval = 60.0;
NSTimeInterval kESReachablityTimeOut = 2.0;

/*
 keys to access the valueDict
 */
NSString *const kESModemDialingKey = @"umts_modemDialing";
NSString *const kESModemConnectKey = @"umts_modemConnect";
NSString *const kESModemBusyKey = @"umts_modemBusy";
NSString *const kESModemDisconnectingKey = @"umts_modemDisconnecting";
NSString *const kESSignalValueKey = @"signalValue";
NSString *const kESSignalPercentKey = @"signalPercent";

@interface ESConnectionThread ()

@property (strong) NSURLConnection *reachablitiyTestConnection;
@property (assign) ESConnectionThreadStatus status;
@property (assign) BOOL canReachRouter;
@property (strong) NSDictionary *valueDict;

- (void)sendNotification;
- (void)updateRouterReachability;
- (void)updateStatus;
- (BOOL)login;
- (BOOL)logout;

@end

@implementation ESConnectionThread

- (void)main {
  // gather credentials
  while(NO == [self isCancelled]) {
    @autoreleasepool {
      [self updateRouterReachability];
      
      if(NO == self.canReachRouter) {
        self.status = ESConnectionStatusOffline;
      }
      else {
        if ([self login]) {
          [self updateStatus];
          [self logout];
        }
      }
      if(self.valueDict != nil) {
        NSLog(@"%@: %@", kESSignalPercentKey, self.valueDict[kESSignalPercentKey]);
        NSLog(@"%@: %@", kESModemBusyKey, self.valueDict[kESModemBusyKey]);
        NSLog(@"%@: %@", kESModemConnectKey, self.valueDict[kESModemConnectKey]);
        NSLog(@"%@: %@", kESModemDialingKey, self.valueDict[kESModemDialingKey]);
        NSLog(@"%@: %@", kESModemDisconnectingKey, self.valueDict[kESModemDisconnectingKey]);
      }
      [NSThread sleepForTimeInterval:kESConnectionThreadSleepInterval];
    }
  }
}

- (void)sendNotification {
  NSDictionary *userInfo = @{ ESConnectionThreadConnectionStatusKey: @(self.status), ESConnectionThreadSignalStrengthKey: @1.0 };
  [[NSNotificationCenter defaultCenter] postNotificationName:ESConnectionThreadStatusUpdateNotification object:self userInfo:userInfo];
}

- (void)updateRouterReachability {
  NSURL *routerURL = [NSURL URLWithString:kESRouterURLString];
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:routerURL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:kESReachablityTimeOut];
  NSURLResponse *response = nil;
  NSError *error = nil;
  NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
  self.canReachRouter = ( data != nil);
}


- (void)updateStatus {
  NSURL *statusURL = [NSURL URLWithString:kESConnectionThreadStatusUrl];
  NSError *error = nil;
  NSString *htmlFile = [NSString stringWithContentsOfURL:statusURL encoding:NSWindowsCP1252StringEncoding error:&error];
  if(htmlFile == nil) {
    self.status = ESConnectionStatusOffline;
    self.valueDict = nil;
    return; // nothing to do, connection error
  }
  else {
    NSArray *lines = [htmlFile paragraphesInString];
    NSMutableDictionary *assignmentDict = [NSMutableDictionary dictionaryWithCapacity:[lines count]];
    for(NSString *line in lines) {
      if([line hasPrefix:@"var "]) {
        NSRange varRange = NSMakeRange(4, [line length] - 5);
        NSString *assignment = [line substringWithRange:varRange];
        NSRange firstEqualSign = [assignment rangeOfString:@"="];
        if(firstEqualSign.location == NSNotFound) {
          continue;
        }
        NSCharacterSet *trimSet = [NSCharacterSet whitespaceCharacterSet];
        NSString *variableName = [[assignment substringWithRange:NSMakeRange(0, firstEqualSign.location)] stringByTrimmingCharactersInSet:trimSet];
        NSString *valueString = [[assignment substringWithRange:NSMakeRange(firstEqualSign.location + 1, [assignment length] - (firstEqualSign.location + 1))] stringByTrimmingCharactersInSet:trimSet];
        assignmentDict[variableName] = valueString;
      }
    }
    self.valueDict = assignmentDict;
  }
}

- (BOOL)login {
  ESCredentialManager *credintialManager = [ESCredentialManager defaultManager];
  NSString *loginUrlString = [NSString stringWithFormat:kESConnectionThreadLoginUrl, credintialManager.login, credintialManager.password];
  NSURL *loginURL = [NSURL URLWithString:loginUrlString];
  NSError *loginError = nil;
  NSString *loginPage = [NSString stringWithContentsOfURL:loginURL encoding:NSWindowsCP1252StringEncoding error:&loginError];
  if(loginPage == nil) {
    return false;
  }
  NSRange loginSuccessNeedle = [loginPage rangeOfString:kESConnectionThreadLoginSuccessNeedle];
  return (loginSuccessNeedle.location != NSNotFound);
}

- (BOOL)logout {
  NSURL *logoutURL = [NSURL URLWithString:kESConnectionThreadLogOutUrl];
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:logoutURL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:kESReachablityTimeOut];
  NSURLResponse *response = nil;
  NSError *error = nil;
  NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
  return (data != nil);
}

@end
