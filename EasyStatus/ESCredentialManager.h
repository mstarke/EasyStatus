//
//  ESCredentialManager.h
//  EasyStatus
//
//  Created by Michael Starke on 24.12.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESCredentialManager : NSObject

@property (weak, nonatomic, readonly) NSString *password;
@property (weak, nonatomic, readonly) NSString *login;

+ (ESCredentialManager *)defaultManager;

- (void)updateLogin:(NSString *)login password:(NSString *)password;

@end
