//
//  ESConnectionDataDelegate.m
//  EasyStatus
//
//  Created by Michael Starke on 14.10.12.
//  Copyright (c) 2012 HicknHack Software GmbH. All rights reserved.
//

#import "ESConnectionDataDelegate.h"

NSString *const kLoginPageNeedle = @"<p class=loginmsg>";

@interface ESConnectionDataDelegate ()

@property (assign) BOOL isAuthenticed;
@property (strong) NSMutableData *recievedData;
@property (strong) NSString *htmlSource;

@end

@implementation ESConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  if(self.recievedData != nil) {
    self.recievedData = nil;
  }
  [_recievedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  self.recievedData = nil;
  self.htmlSource = [[NSString alloc] initWithData:self.recievedData encoding:NSWindowsCP1252StringEncoding];

  NSRange hitRange = [_htmlSource rangeOfString:kLoginPageNeedle options:NSCaseInsensitiveSearch];
  self.isAuthenticed = (hitRange.location == NSNotFound);
  NSLog(@"%@: Finished recieving data.", self);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  NSLog(@"Connection failed");
}

@end
