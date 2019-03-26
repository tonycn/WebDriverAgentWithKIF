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

- (void)executeOn:(UIView * _Nullable)element
      finishBlock:(void (^)(BOOL))finishBlock
{
  if (element) {
    [element tap];
    finishBlock(YES);
  } else {
    finishBlock(NO);
  }
}

+ (NSString *)actionString
{
    return @"tap";
}

@end
