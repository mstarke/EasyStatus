//
//  ESConnectionThread.h
//  EasyStatus
//
//  Created by Michael Starke on 23.12.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

APPKIT_EXTERN NSString *const ESConnectionThreadStatusUpdateNotification;
APPKIT_EXTERN NSString *const ESConnectionThreadSignalStrengthKey;
APPKIT_EXTERN NSString *const ESConnectionThreadConnectionStatusKey;

typedef enum {
  ESConnectionStatusRouterUnreachable,
  ESConnectioNStatusConnectionOnline,
  ESConnectionStatusConnectionOffline
}
ESConnectionStatus;

@interface ESConnectionThread : NSThread <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (assign, readonly) ESConnectionStatus status;

@end
