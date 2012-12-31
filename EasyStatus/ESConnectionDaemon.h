//
//  ESConnectionDaemon.h
//  EasyStatus
//
//  Created by Michael Starke on 23.12.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

APPKIT_EXTERN NSString *const ESConnectionDaemonStatusUpdateNotification;
APPKIT_EXTERN NSString *const ESConnectionDaemonSignalStrengthKey;
APPKIT_EXTERN NSString *const ESConnectionDaemonConnectionStatusKey;

typedef enum {
  ESConnectionStatusRouterUnreachable,
  ESConnectioNStatusConnectionOnline,
  ESConnectionStatusConnectionOffline
}
ESConnectionStatus;

@interface ESConnectionDaemon : NSObject

@property (nonatomic, weak, readonly) NSString *statusDescription;
@property (nonatomic, weak, readonly) NSString *log;

+ (ESConnectionDaemon *)defaultDaemon;

- (void)enableMonitoring;
- (void)cancelMonitoring;
- (void)restartRouter;

@end
