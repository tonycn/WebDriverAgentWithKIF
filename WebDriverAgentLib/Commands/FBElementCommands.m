/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBElementCommands.h"

#import "FBApplication.h"
#import "FBConfiguration.h"
#import "FBKeyboard.h"
#import "FBPredicate.h"
#import "FBRoute.h"
#import "FBRouteRequest.h"
#import "FBRunLoopSpinner.h"
#import "FBErrorBuilder.h"
#import "FBSession.h"
#import "FBApplication.h"
#import "FBMacros.h"
#import "FBMathUtils.h"
#import "FBRuntimeUtils.h"
#import "NSPredicate+FBFormat.h"
#import "UIView+FBHelper.h"
#import "FBElementCache.h"
#import "FBUITestScript.h"
#import "FBResponseFuturePayload.h"
#import "UIView-KIFAdditions.h"
#import "KIFTypist.h"
#import "FBUIDismissKeyboardCommand.h"
#import "FBUIScrollCommand.h"

@interface FBElementCommands ()
@end

@implementation FBElementCommands

#pragma mark - <FBCommandHandler>

+ (NSArray *)routes
{
  return
  @[
    [[FBRoute GET:@"/window/size"] respondWithTarget:self action:@selector(handleGetWindowSize:)],
    [[FBRoute POST:@"/element/:uuid/click"] respondWithTarget:self action:@selector(handleClick:)],
    [[FBRoute POST:@"/element/:uuid/clear"] respondWithTarget:self action:@selector(handleClear:)],
 
    [[FBRoute POST:@"/command"] respondWithTarget:self action:@selector(handleCommand:)],
    [[FBRoute POST:@"/keys"] respondWithTarget:self action:@selector(handleKeys:)],
    [[FBRoute POST:@"/keyboard/dismiss"] respondWithTarget:self action:@selector(handleKeyboardDismiss:)],
    [[FBRoute POST:@"/scroll"] respondWithTarget:self action:@selector(handleScroll:)],

    [[FBRoute POST:@"/wda/tap/:uuid"] respondWithTarget:self action:@selector(handleTap:)],
    
//    [[FBRoute POST:@"/wda/element/:uuid/dragfromtoforduration"] respondWithTarget:self action:@selector(handleDrag:)],
//    [[FBRoute POST:@"/wda/dragfromtoforduration"] respondWithTarget:self action:@selector(handleDragCoordinate:)],
  ];
}


#pragma mark - Commands

+ (id<FBResponsePayload>)handleClick:(FBRouteRequest *)request
{
  FBElementCache *elementCache = request.session.elementCache;
  NSString *elementUUID = request.parameters[@"uuid"];
  UIView *element = [elementCache elementForUUID:elementUUID];
  NSError *error = nil;
  [element tap];
  return FBResponseWithElementUUID(elementUUID);
}

+ (id<FBResponsePayload>)handleClear:(FBRouteRequest *)request
{
  FBElementCache *elementCache = request.session.elementCache;
  NSString *elementUUID = request.parameters[@"uuid"];
  UIView *element = [elementCache elementForUUID:elementUUID];
  NSError *error;
  if (![element fb_clearTextWithError:&error]) {
    return FBResponseWithError(error);
  }
  return FBResponseWithElementUUID(elementUUID);
}

+ (id<FBResponsePayload>)handleDoubleTap:(FBRouteRequest *)request
{
  FBElementCache *elementCache = request.session.elementCache;
  UIView *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
  [element tap];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [element tap];
  });
  return FBResponseWithOK();
}

+ (id<FBResponsePayload>)handleScroll:(FBRouteRequest *)request
{
  CGFloat x = [request.arguments[@"x"] floatValue];
  CGFloat y = [request.arguments[@"y"] floatValue];
  NSString *until = request.arguments[@"until"];
  NSString *onElement = request.arguments[@"path"];

  FBResponseFuturePayload *future = [[FBResponseFuturePayload alloc] init];
  FBUIScrollCommand *command = [FBUITestScript generateCommandByAction:[FBUIScrollCommand actionString]
                                                          classChain:onElement];
  command.x = x;
  command.y = y;
  command.until = until;
  
  if (command.x < 1 && command.y < 1) {
    return FBResponseWithErrorFormat(@"Unsupported scroll type");
  }
  
  [command waitUntilElement:^(UIView * _Nullable element) {
    UIScrollView *scrollView = nil;
    if ([element isKindOfClass:UIScrollView.class]) {
      scrollView = element;
    } else {
      scrollView = (id)[element fb_findSuperViewOfClass:UIScrollView.class];
    }
    [command executeOn:scrollView finishBlock:^(BOOL succ) {
      if (succ) {
        [command reducePathIfPossibleForElement:scrollView];
        id<FBResponsePayload> payload = FBResponseWithObject(command.toResponsePayloadObject);
        [future fillRealResponsePayload:payload];
      } else {
        [future fillRealResponsePayload:FBResponseWithErrorFormat(@"Unsupported scroll type")];
      }
    }];
  }];
  return future;
}

+ (id<FBResponsePayload>)handleDragCoordinate:(FBRouteRequest *)request
{
  FBSession *session = request.session;
  CGPoint startPoint = CGPointMake((CGFloat)[request.arguments[@"fromX"] doubleValue], (CGFloat)[request.arguments[@"fromY"] doubleValue]);
  CGPoint endPoint = CGPointMake((CGFloat)[request.arguments[@"toX"] doubleValue], (CGFloat)[request.arguments[@"toY"] doubleValue]);
  NSTimeInterval duration = [request.arguments[@"duration"] doubleValue];
  
  [request.session.application.fb_keyWindow dragFromPoint:startPoint toPoint:endPoint];
  return FBResponseWithOK();
}

+ (id<FBResponsePayload>)handleDrag:(FBRouteRequest *)request
{
  FBSession *session = request.session;
  FBElementCache *elementCache = session.elementCache;
  UIView *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
  CGPoint startPoint = CGPointMake((CGFloat)(element.frame.origin.x + [request.arguments[@"fromX"] doubleValue]), (CGFloat)(element.frame.origin.y + [request.arguments[@"fromY"] doubleValue]));
  CGPoint endPoint = CGPointMake((CGFloat)(element.frame.origin.x + [request.arguments[@"toX"] doubleValue]), (CGFloat)(element.frame.origin.y + [request.arguments[@"toY"] doubleValue]));
  NSTimeInterval duration = [request.arguments[@"duration"] doubleValue];
  [element dragFromPoint:startPoint toPoint:endPoint];
  return FBResponseWithOK();
}

+ (id<FBResponsePayload>)handleSwipe:(FBRouteRequest *)request
{
    FBElementCache *elementCache = request.session.elementCache;
    UIView *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
    NSString *const direction = request.arguments[@"direction"];
    if (!direction) {
        return FBResponseWithErrorFormat(@"Missing 'direction' parameter");
    }
  return FBResponseWithErrorFormat(@"Unsupported swipe type");
}

+ (id<FBResponsePayload>)handleTap:(FBRouteRequest *)request
{
  FBElementCache *elementCache = request.session.elementCache;
  CGPoint tapPoint = CGPointMake((CGFloat)[request.arguments[@"x"] doubleValue], (CGFloat)[request.arguments[@"y"] doubleValue]);
  UIView *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
  if (nil == element) {
    for (UIWindow *window in request.session.application.fb_reversedWindows) {
      UIView * view = [window hitTest:tapPoint withEvent:nil];
      if (view) {
        tapPoint = [window convertPoint:tapPoint toView:view];
        element = view;
        break;
      }
    }
  }
  
  FBUIBaseCommand *command = [FBUITestScript generateCommandByAction:@"tap"
                                                          classChain:[element fb_generateElementClassChain]];
  [command reducePathIfPossibleForElement:element];
  [element tapAtPoint:tapPoint];
  return  FBResponseWithObject(command.toResponsePayloadObject);
}

+ (id<FBResponsePayload>)handleCommand:(FBRouteRequest *)request
{
  NSString *action = request.arguments[@"action"];
  NSString *classChain = request.arguments[@"classChain"];
  FBResponseFuturePayload *future = [[FBResponseFuturePayload alloc] init];
  FBUIBaseCommand *command = [FBUITestScript generateCommandByAction:action
                                                          classChain:classChain];
  [command waitUntilElement:^(UIView * _Nullable element) {
    if (element) {
      [command reducePathIfPossibleForElement:element];
      [command executeOn:element finishBlock:^(BOOL succ) {
        id<FBResponsePayload> payload = FBResponseWithObject(command.toResponsePayloadObject);
        [future fillRealResponsePayload:payload];
      }];
      id<FBResponsePayload> payload = FBResponseWithObject(command.toResponsePayloadObject);
      [future fillRealResponsePayload:payload];
    } else {
      [future fillRealResponsePayload:FBResponseWithStatus(FBCommandStatusNoSuchElement, request.arguments)];
    }
  }];
  return future;
}

+ (id<FBResponsePayload>)handleKeys:(FBRouteRequest *)request
{
  NSString *textToType = [request.arguments[@"value"] componentsJoinedByString:@""];
  NSUInteger frequency = [request.arguments[@"frequency"] unsignedIntegerValue] ?: [FBConfiguration maxTypingFrequency];
  [KIFTypist enterCharacter:textToType];
  return FBResponseWithOK();
}

+ (id<FBResponsePayload>)handleKeyboardDismiss:(FBRouteRequest *)request
{
  FBUIBaseCommand *command = [[FBUIDismissKeyboardCommand alloc] init];
  [command executeOn:nil finishBlock:^(BOOL succ) {
    // log succ or not
  }];
  id<FBResponsePayload> payload = FBResponseWithObject(command.toResponsePayloadObject);
  return payload;
}

+ (id<FBResponsePayload>)handleGetWindowSize:(FBRouteRequest *)request
{
  CGRect frame = request.session.application.wdFrame;
  CGSize screenSize = FBAdjustDimensionsForApplication(frame.size, request.session.application.interfaceOrientation);
  return FBResponseWithStatus(FBCommandStatusNoError, @{
    @"width": @(screenSize.width),
    @"height": @(screenSize.height),
  });
}

@end
