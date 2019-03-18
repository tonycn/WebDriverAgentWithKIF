//
//  FBUIBaseCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-18.
//

#import "FBUIBaseCommand.h"

#import "FBSession.h"
#import "FBApplication.h"
#import "FBResponsePayload.h"
#import "FBElementCache.h"
#import "UIView-KIFAdditions.h"
#import "UIView+FBHelper.h"

@implementation FBUIBaseCommand

- (BOOL)execute
{
  return NO;
}

- (NSArray <UIView *> *)findElementsByClassChain:(NSString *)classChain
                     shouldReturnAfterFirstMatch:(BOOL)shouldReturnAfterFirstMatch
{
  
  FBSession *session = [FBSession activeSession];
  NSMutableArray *foundElements = [NSMutableArray array];
  for (UIWindow *window in session.application.fb_reversedWindows) {
    NSArray *elements = [window fb_descendantsMatchingClassChain:classChain
                                     shouldReturnAfterFirstMatch:shouldReturnAfterFirstMatch];
    if (elements) {
      [foundElements addObjectsFromArray:elements];
    }
  }
  return foundElements;
}

@end
