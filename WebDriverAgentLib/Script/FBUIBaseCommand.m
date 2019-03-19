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

- (void)executeWithResultBlock:(void (^)(BOOL))resultBlock
{
  resultBlock(NO);
}

+ (NSArray <UIView *> *)findElementsByClassChain:(NSString *)classChain
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

+ (void)findElementByClassChain:(NSString *)classChain
    shouldReturnAfterFirstMatch:(BOOL)shouldReturnAfterFirstMatch
                        timeout:(NSTimeInterval)timeout
                elementsDidFind:(void (^)(NSArray <UIView *> *))elementsDidFind
{
  NSArray <UIView *> *elements = [self findElementsByClassChain:classChain
                                    shouldReturnAfterFirstMatch:shouldReturnAfterFirstMatch];
  if (elements.count > 0) {
    elementsDidFind(elements);
  } else {
    if (timeout > 0) {
      const NSTimeInterval minDelay = 0.1;
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(minDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self findElementByClassChain:classChain
          shouldReturnAfterFirstMatch:shouldReturnAfterFirstMatch
                              timeout:timeout - minDelay
                      elementsDidFind:elementsDidFind];
      });
    }
  }
}

@end
