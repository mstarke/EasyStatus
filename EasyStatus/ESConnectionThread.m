//
//  ESConnectionThread.m
//  EasyStatus
//
//  Created by Michael Starke on 23.12.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "ESConnectionThread.h"

NSString *const ESConnectionThreadStatusUpdateNotification  = @"ESConnectionThreadStatusUpdateNotification";
NSString *const ESConnectionThreadSignalStrengthKey         = @"ESConnectionThreadSignalStrengthKey";
NSString *const ESConnectionThreadConnectionStatusKey       = @"ESConnectionThreadConnectionStatusKey";

/*
 Private constants
 */
NSString *const kESRouterURLString = @"http://easy.box";
NSString *const kESConnectionThreadLoginUrl = @"cgi-bin/login.exe?user=%@&pws=%@";
NSString *const kESConnectionThreadStatusUrl = @"status_main.stml";
NSString *const kESConnectionThreadSignalPercentNeedle = @"var signalPercent=";
NSTimeInterval kESConnectionThreadSleepInterval = 10.0;
NSTimeInterval kESReachablityTimeOut = 2.0;

NSString *const kESConnectionThreadLoginPageNeedle = @"<p class=loginmsg>";
static BOOL kDidCheckReachablity = NO;


@interface ESConnectionThread ()

@property (strong) NSURLConnection *reachablitiyTestConnection;
@property (assign) ESConnectionThreadStatus status;
@property (assign) BOOL canReachRouter;

- (void)sendNotification;

@end

@implementation ESConnectionThread

- (void)main {
  // gather credentials
  while(NO == [self isCancelled]) {
    @autoreleasepool {
      // test if easybox is reachable
      kDidCheckReachablity = NO;
      NSURL *routerURL = [NSURL URLWithString:kESRouterURLString];
      NSURLRequest *urlRequest = [NSURLRequest requestWithURL:routerURL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:kESReachablityTimeOut];
      NSURLResponse *response = nil;
      NSError *error = nil;
      NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
      self.canReachRouter = ( data != nil);
      if(NO == self.canReachRouter) {
        self.status = ESConnectionStatusOffline;
        NSLog(@"Error while trying to connect to router: %@", [error localizedDescription]);
      }
      else {
        self.status = ESConnectionStatusUnknown;
      }
      NSLog(@"Router is %@reachable", self.canReachRouter ? @"" : @"not ");
      if(self.canReachRouter) {
        NSStringEncoding encoding;
        error = nil;       
        NSString *htmlFile = [NSString stringWithContentsOfURL:routerURL usedEncoding:&encoding error:&error];
        NSLog(@"%@", htmlFile);
      }
      [NSThread sleepForTimeInterval:kESConnectionThreadSleepInterval];
    }
  }
}

- (void)sendNotification {
  NSDictionary *userInfo = @{ ESConnectionThreadConnectionStatusKey: @(self.status), ESConnectionThreadSignalStrengthKey: @1.0 };
  [[NSNotificationCenter defaultCenter] postNotificationName:ESConnectionThreadStatusUpdateNotification object:self userInfo:userInfo];
}

@end
