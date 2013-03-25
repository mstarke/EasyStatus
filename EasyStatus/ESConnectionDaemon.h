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
  ESConnectionStatusRouterUnreachable, // Router is not reachable
  ESConnectionStatusOtherUserLoggedIn, // Another user is logged in into the admin interface
  ESConnectioNStatusConnectionOnline, // Online, internet available
  ESConnectionStatusConnectionOffline, // Offline, no internet connection
  ESConnectionStatusConnectionDialing // Modem is dialing
}
ESConnectionStatus;

NSError *error;

@interface ESConnectionDaemon : NSObject

@property (nonatomic, weak, readonly) NSString *log;

+ (ESConnectionDaemon *)defaultDaemon;

- (void)enableMonitoring;
- (void)cancelMonitoring;
- (void)restartRouter;

@end
