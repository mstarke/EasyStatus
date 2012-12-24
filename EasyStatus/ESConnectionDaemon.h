//
//  ESConnectionDaemon.h
//  EasyStatus
//
//  Created by Michael Starke on 23.12.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESConnectionDaemon : NSObject

@property (nonatomic, weak, readonly) NSString *statusDescription;

+ (ESConnectionDaemon *)defaultDaemon;

- (void)enableMonitoring;
- (void)cancelMonitoring;
- (void)restartRouter;

@end
