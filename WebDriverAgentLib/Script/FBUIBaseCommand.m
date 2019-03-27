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

- (instancetype)initWithAttributes:(NSDictionary *)attrs {
    self = [super init];
    if (self) {
      self.action = [self.class actionString];
      self.path = attrs[@"path"];
      self.originCommandDict = attrs;
    }
    return self;
}

- (void)waitUntilElement:(void (^)(UIView * _Nullable element))resultBlock
{
  const NSTimeInterval defaultTimeout = 1;
  [self.class findElementByClassChain:self.path
          shouldReturnAfterFirstMatch:YES
                              timeout:defaultTimeout
                      elementsDidFind:^(NSArray<UIView *> * _Nonnull elements) {
    resultBlock(elements.firstObject);
  }];
}

- (void)executeOn:(UIView * _Nullable)element
      finishBlock:(void (^)(BOOL))finishBlock
{
  finishBlock(NO);
}

- (void)executeWithResultBlock:(void (^)(BOOL succ, UIView * _Nullable element))resultBlock
{
  if (self.elementIgnored) {
    [self executeOn:nil finishBlock:^(BOOL succ) {
      resultBlock(succ, nil);
    }];
  } else {
    [self waitUntilElement:^(UIView * _Nullable element) {
      if (element) {
        [self executeOn:element finishBlock:^(BOOL succ) {
          resultBlock(succ, nil);
        }];
      } else {
        resultBlock(NO, nil);
      }
    }];
  }
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.action forKey:@"action"];
    if (self.path.length > 0) {
        [dict setObject:self.path forKey:@"path"];
    }
    return dict;
}

- (NSDictionary *)toResponsePayloadObject
{
  return @{@"command": self.toDictionary};
}

- (void)reducePathIfPossibleForElement:(UIView *)element
{
  for (NSInteger pathLevel = 2; pathLevel <= 5; ++pathLevel) {
    NSString *reducedPath = [element fb_generateElementReducedClassChainByMaxLevel:pathLevel];
    NSArray *findElements = [self.class findElementsByClassChain:reducedPath shouldReturnAfterFirstMatch:NO];
    if (findElements.count == 1 && findElements.firstObject == element) {
      self.path = reducedPath;
      break;
    }
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
