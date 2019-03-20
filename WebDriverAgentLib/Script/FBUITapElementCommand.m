//
//  FBUITapCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-18.
//

#import "FBUITapElementCommand.h"

#import "FBSession.h"
#import "FBApplication.h"
#import "FBResponsePayload.h"
#import "FBElementCache.h"
#import "UIView-KIFAdditions.h"
#import "UIView+FBHelper.h"

@implementation FBUITapElementCommand

- (BOOL)executeOn:(UIView *)element
{
  if (element) {
    [element tap];
    return YES;
  } else {
    return NO;
  }
}

+ (NSString *)actionString
{
    return @"tap";
}

@end
