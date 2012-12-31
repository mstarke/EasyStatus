//
//  ESConnectionDaemon.m
//  EasyStatus
//
//  Created by Michael Starke on 23.12.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "ESConnectionDaemon.h"
#import "ESCredentialManager.h"
#import "NSString+ESStringAdditions.h"

typedef struct {
  NSInteger signalStrength;
  ESConnectionStatus status;
} ESConnectionStatusData;

NSString *const ESConnectionDaemonStatusUpdateNotification  = @"ESConnectionThreadStatusUpdateNotification";
NSString *const ESConnectionDaemonSignalStrengthKey         = @"ESConnectionThreadSignalStrengthKey";
NSString *const ESConnectionDaemonConnectionStatusKey       = @"ESConnectionThreadConnectionStatusKey";

/*
 Private constants
 */
NSString *const kESRouterURLString = @"http://easy.box";
NSString *const kESConnectionDaemonLoginUrl = @"http://easy.box/cgi-bin/login.exe?user=%@&pws=%@";
NSString *const kESConnectionDaemonStatusUrl = @"http://easy.box/status_main.stm";
NSString *const kESConnectionDaemonLogOutUrl = @"http://easy.box/cgi-bin/logout.exe";
NSString *const kESConnectionDaemonRestartUrl = @"http://easy.box/cgi-bin/restart.exe";
NSString *const kESConnectionDaemonLoginSuccessNeedle = @"setupa_brief.stm";
NSTimeInterval kESConnectionDaemonSleepInterval = 30.0;
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


@interface ESConnectionDaemon ()

@property (strong) NSThread *statusThread;
@property (strong) NSURLConnection *reachablitiyTestConnection;
@property (assign) ESConnectionStatusData statusData;

- (void)postStatusChangedNotification;
- (ESConnectionStatusData)readStatus;
- (BOOL)importStatus:(ESConnectionStatusData) data;
- (BOOL)login;
- (BOOL)logout;
- (void)update;

@end

@implementation ESConnectionDaemon

+ (ESConnectionDaemon *)defaultDaemon {
  static ESConnectionDaemon *sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[ESConnectionDaemon alloc] init];
  });
  return sharedInstance;
}

- (NSString *)statusDescription {
  return @"status";
}

- (NSString *)log {
  return @"Log";
}

- (void)enableMonitoring {
  if(self.statusThread == nil) {
    self.statusThread = [[NSThread alloc] initWithTarget:self selector:@selector(update) object:nil];
  }
  [self.statusThread start];
}

- (void)cancelMonitoring {
  if(self.statusThread) {
    [self.statusThread cancel];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^(void){
      while([self.statusThread isExecuting]) {
        sleep(1);
      }
      dispatch_async(dispatch_get_main_queue(), ^(void){
        self.statusThread = nil;
      });
    });
  }
}

- (void)update {
  while(NO == [self.statusThread isCancelled]) {
    @autoreleasepool {
      ESConnectionStatusData statusData = { -1, ESConnectionStatusRouterUnreachable };
      if ([self login]) {
        statusData = [self readStatus];
        [self logout];
      }
      if([self importStatus:statusData]) {
        [self postStatusChangedNotification];
      }
      [NSThread sleepForTimeInterval:kESConnectionDaemonSleepInterval];
    }
  }
}

- (void)postStatusChangedNotification {
  NSDictionary *userInfo = @{
    ESConnectionDaemonConnectionStatusKey: @(self.statusData.status),
    ESConnectionDaemonSignalStrengthKey: @(self.statusData.signalStrength)
  };
  dispatch_async(dispatch_get_main_queue(), ^(void){
    [[NSNotificationCenter defaultCenter] postNotificationName:ESConnectionDaemonStatusUpdateNotification
                                                        object:self
                                                      userInfo:userInfo];
  });
}

- (ESConnectionStatusData)readStatus {
  ESConnectionStatusData statusData = { -1, ESConnectionStatusConnectionOffline };
  NSURL *statusURL = [NSURL URLWithString:kESConnectionDaemonStatusUrl];
  NSError *error = nil;
  NSString *htmlFile = [NSString stringWithContentsOfURL:statusURL
                                                encoding:NSWindowsCP1252StringEncoding
                                                   error:&error];
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
  NSString *loginUrlString = [NSString stringWithFormat:kESConnectionDaemonLoginUrl, credintialManager.login, credintialManager.password];
  NSURL *loginURL = [NSURL URLWithString:loginUrlString];
  NSError *loginError = nil;
  NSString *loginPage = [NSString stringWithContentsOfURL:loginURL encoding:NSWindowsCP1252StringEncoding error:&loginError];
  if(loginPage == nil) {
    return false;
  }
  NSRange loginSuccessNeedle = [loginPage rangeOfString:kESConnectionDaemonLoginSuccessNeedle];
  return (loginSuccessNeedle.location != NSNotFound);
}

- (BOOL)logout {
  NSURL *logoutURL = [NSURL URLWithString:kESConnectionDaemonLogOutUrl];
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:logoutURL
                                              cachePolicy:NSURLCacheStorageNotAllowed
                                          timeoutInterval:kESReachablityTimeOut];
  NSURLResponse *response = nil;
  NSError *error = nil;
  NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                       returningResponse:&response
                                                   error:&error];
  return (data != nil);
}

- (void)restartRouter {
  [self cancelMonitoring];
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue, ^(void){
    if(self.login) {
      NSURL *resetURL = [NSURL URLWithString:kESConnectionDaemonRestartUrl];
      NSURLRequest *urlRequest = [NSURLRequest requestWithURL:resetURL
                                                  cachePolicy:NSURLCacheStorageNotAllowed
                                              timeoutInterval:kESReachablityTimeOut];
      NSURLResponse *response = nil;
      NSError *error = nil;
      [NSURLConnection sendSynchronousRequest:urlRequest
                            returningResponse:&response
                                        error:&error];
    }
    dispatch_async(dispatch_get_main_queue(), ^(void){
      [self enableMonitoring];
    });
  });}



@end
