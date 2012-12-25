//
//  NSString+ESStringAdditions.m
//  EasyStatus
//
//  Created by Michael Starke on 25.12.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "NSString+ESStringAdditions.h"

@implementation NSString (ESStringAdditions)

+ (NSArray *)arrayWithParagraphesInString:(NSString *)string {
  return [string paragraphesInString];
}

- (NSArray *)paragraphesInString {
  NSUInteger length = [self length];
  NSUInteger paraStart = 0, paraEnd = 0, contentsEnd = 0;
  NSMutableArray *array = [NSMutableArray array];
  NSRange currentRange;
  while (paraEnd < length) {
    [self getParagraphStart:&paraStart end:&paraEnd
                  contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
    currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
    [array addObject:[self substringWithRange:currentRange]];
  }
  return array;
}

@end
