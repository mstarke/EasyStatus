//
//  ESLogController.m
//  EasyStatus
//
//  Created by Michael Starke on 27.12.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "ESLogController.h"
#import "ESConnectionDaemon.h"

@interface ESLogController ()

@end

@implementation ESLogController

- (id)initWithWindow:(NSWindow *)window {
  self = [super initWithWindow:window];
  if (self) {
    self.window = window;
  }
  return self;
}

- (void)windowDidLoad {
  [super windowDidLoad];
  NSString *log = [ESConnectionDaemon defaultDaemon].log;
  [self.logTextField setStringValue:log];
}

- (IBAction)toggleReload:(id)sender {
}
@end
