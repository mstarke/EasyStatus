//
//  ESLogController.h
//  EasyStatus
//
//  Created by Michael Starke on 27.12.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ESLogController : NSWindowController
@property (weak) IBOutlet NSTextField *logTextField;
@property (weak) IBOutlet NSButton *reloadButton;
@property (nonatomic, assign) BOOL realoadLog;

@end
