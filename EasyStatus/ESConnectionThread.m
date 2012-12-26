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

typedef struct {
  NSInteger signalStrength;
  ESConnectionStatus status;
} ESConnectionStatusData;

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
NSTimeInterval kESConnectionThreadSleepInterval = 5.0;
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
@property (assign) ESConnectionStatusData statusData;

- (void)postStatusChangedNotification;
- (ESConnectionStatusData)readStatus;
- (BOOL)importStatus:(ESConnectionStatusData) data;
- (BOOL)login;
- (BOOL)logout;

@end

@implementation ESConnectionThread

- (void)main {
  // gather credentials
  while(NO == [self isCancelled]) {
    @autoreleasepool {
      ESConnectionStatusData statusData = { -1, ESConnectionStatusRouterUnreachable };
      if ([self login]) {
        statusData = [self readStatus];
        [self logout];
      }
      if([self importStatus:statusData]) {
        [self postStatusChangedNotification];
      }
      [NSThread sleepForTimeInterval:kESConnectionThreadSleepInterval];
    }
  }
}

- (void)postStatusChangedNotification {
  NSDictionary *userInfo = @{ ESConnectionThreadConnectionStatusKey: @(self.statusData.status), ESConnectionThreadSignalStrengthKey: @(self.statusData.signalStrength) };
  [[NSNotificationCenter defaultCenter] postNotificationName:ESConnectionThreadStatusUpdateNotification object:self userInfo:userInfo];
}

- (ESConnectionStatusData)readStatus {
  ESConnectionStatusData statusData = { -1, ESConnectionStatusConnectionOffline };
  NSURL *statusURL = [NSURL URLWithString:kESConnectionThreadStatusUrl];
  NSError *error = nil;
  NSString *htmlFile = [NSString stringWithContentsOfURL:statusURL encoding:NSWindowsCP1252StringEncoding error:&error];
  if(htmlFile != nil) {
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
    NSString *signalString = assignmentDict[kESSignalPercentKey];
    if(signalString) {
      NSScanner *signalScanner = [NSScanner scannerWithString:signalString];
      [signalScanner scanInteger:&statusData.signalStrength];
    }
    NSString *connectionString = assignmentDict[kESModemConnectKey];
    if(connectionString) {
      if( NSOrderedSame == [connectionString compare:@"true" options:NSCaseInsensitiveSearch] ) {
        statusData.status = ESConnectioNStatusConnectionOnline;
      }
      if( NSOrderedSame == [connectionString compare:@"false" options:NSCaseInsensitiveSearch] ) {
        statusData.status = ESConnectionStatusConnectionOffline;
      }
    }
  }
  return statusData;
}

- (BOOL)importStatus:(ESConnectionStatusData)data {
  ESConnectionStatusData myData = self.statusData;
  BOOL didChange = NO;
  if(myData.signalStrength != data.signalStrength ) {
    didChange = YES;
    myData.signalStrength = data.signalStrength;
  }
  if(myData.status != data.status) {
    didChange = YES;
    myData.status = data.status;
  }
  if(didChange) {
    self.statusData = myData;
  }
  return didChange; 
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
