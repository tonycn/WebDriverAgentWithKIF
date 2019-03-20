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
#import "FBClassChainQueryParser.h"

NSString * FBUICommandErrorDomain = @"FBUICommandErrorDomain";
NSString * FBUICommandErrorInfoKeyReason = @"reason";


@implementation FBUIBaseCommand

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timeout = 1.0;
    }
    return self;
}

- (void)executeWithResultBlock:(void (^)(BOOL))resultBlock
{
  resultBlock(NO);
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.action forKey:@"action"];
    if (self.path.length > 0) {
        [dict setObject:self.path forKey:@"path"];
    }
    if (self.props) {
        [dict setObject:self.props forKey:@"props"];
    }
    [dict setObject:@(self.timeout) forKey:@"timeout"];
    return dict;
}

- (void)reducePathIfPossibleForElement:(UIView *)element
{
  NSString *reducedPath = [element fb_generateElementReducedClassChain];
  NSArray *findElements = [self.class findElementsByClassChain:reducedPath shouldReturnAfterFirstMatch:NO];
  if (findElements.count == 1) {
    self.path = reducedPath;
  }
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

+ (NSString *)actionString
{
    return @"Not supported";
}

- (NSError *)commandError
{
  NSString *errorReason = [NSJSONSerialization dataWithJSONObject:self.originCommandDict options:0 error:NULL];
  errorReason = errorReason ?: @"unkonwn reason";
  NSError *error = [NSError errorWithDomain:FBUICommandErrorDomain
                                       code:1
                                   userInfo:@{FBUICommandErrorInfoKeyReason:errorReason}];
  return error;
}

@end
