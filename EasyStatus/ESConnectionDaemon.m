//
//  ESConnectionDaemon.m
//  EasyStatus
//
//  Created by Michael Starke on 23.12.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "ESConnectionDaemon.h"
#import "ESConnectionThread.h"

@interface ESConnectionDaemon ()

@property (strong) ESConnectionThread *statusThread;

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

- (void)enableMonitoring {
  if(nil == self.statusThread) {
    self.statusThread = [[ESConnectionThread alloc] init];
    // register for status notification?
  }
  [self.statusThread start];
}

- (void)cancelMonitoring {
  if(self.statusThread) {
    [self.statusThread cancel];
    self.statusThread = nil;
  }
}

- (void)restartRouter {
  NSLog(@"Restart router");
}

@end
