//
//  NSString+ESStringAdditions.h
//  EasyStatus
//
//  Created by Michael Starke on 25.12.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ESStringAdditions)

+ (NSArray *)arrayWithParagraphesInString:(NSString *)string;
- (NSArray *)paragraphesInString;

@end
