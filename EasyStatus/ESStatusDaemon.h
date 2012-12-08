//
//  ESStatusDaemon.h
//  EasyStatus
//
//  Created by Michael Starke on 14.10.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

APPKIT_EXTERN NSString *const ESStatusUpdatedNotification;
APPKIT_EXTERN NSString *const kESSignalStrengthKey;
APPKIT_EXTERN NSString *const kESConnectionStatusKey;

@interface ESStatusDaemon : NSObject

@end
