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

@interface FBElementCommands ()
@end

@implementation FBElementCommands

#pragma mark - <FBCommandHandler>

+ (NSArray *)routes
{
  return
  @[
    [[FBRoute GET:@"/window/size"] respondWithTarget:self action:@selector(handleGetWindowSize:)],
    [[FBRoute GET:@"/element/:uuid/rect"] respondWithTarget:self action:@selector(handleGetRect:)],
    [[FBRoute POST:@"/element/:uuid/click"] respondWithTarget:self action:@selector(handleClick:)],
    [[FBRoute POST:@"/element/:uuid/clear"] respondWithTarget:self action:@selector(handleClear:)],
    [[FBRoute GET:@"/element/:uuid/screenshot"] respondWithTarget:self action:@selector(handleElementScreenshot:)],
    
    [[FBRoute POST:@"/command"] respondWithTarget:self action:@selector(handleCommand:)],
    [[FBRoute POST:@"/script"] respondWithTarget:self action:@selector(handleScript:)],
    [[FBRoute POST:@"/keys"] respondWithTarget:self action:@selector(handleKeys:)],

    [[FBRoute POST:@"/wda/tap/:uuid"] respondWithTarget:self action:@selector(handleTap:)],

//    [[FBRoute POST:@"/wda/element/:uuid/scroll"] respondWithTarget:self action:@selector(handleScroll:)],
//    [[FBRoute POST:@"/wda/element/:uuid/dragfromtoforduration"] respondWithTarget:self action:@selector(handleDrag:)],
//    [[FBRoute POST:@"/wda/dragfromtoforduration"] respondWithTarget:self action:@selector(handleDragCoordinate:)],
  ];
}


#pragma mark - Commands

+ (id<FBResponsePayload>)handleGetEnabled:(FBRouteRequest *)request
{
  FBElementCache *elementCache = request.session.elementCache;
  UIView *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
  BOOL isEnabled = [element fb_checkIfEnabled];
  return FBResponseWithStatus(FBCommandStatusNoError, isEnabled ? @YES : @NO);
}

+ (id<FBResponsePayload>)handleGetRect:(FBRouteRequest *)request
{
  FBElementCache *elementCache = request.session.elementCache;
  UIView *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
  return FBResponseWithStatus(FBCommandStatusNoError, element.wdRect);
}

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
  return FBResponseWithErrorFormat(@"Unsupported scroll type");
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
        CGPoint convertedPoint = [window convertPoint:tapPoint toView:view];
        [view tapAtPoint:convertedPoint];
        element = view;
        break;
      }
    }
  } else {
    [element tapAtPoint:tapPoint];
  }
  FBUIBaseCommand *command = [FBUITestScript generateCommandByAction:@"tap"
                                                          classChain:[element fb_generateElementClassChain]];

  return  FBResponseWithObject(@{@"command": command.toDictionary});
}

+ (id<FBResponsePayload>)handleCommand:(FBRouteRequest *)request
{
    NSString *action = request.arguments[@"action"];
    NSString *classChain = request.arguments[@"classChain"];
    FBResponseFuturePayload *future = [[FBResponseFuturePayload alloc] init];
    FBUIBaseCommand *command = [FBUITestScript generateCommandByAction:action
                                                            classChain:classChain];
    [command executeWithResultBlock:^(BOOL succ) {
        id<FBResponsePayload> payload = FBResponseWithObject(@{@"command": command.toDictionary});
        [future fillRealResponsePayload:payload];
    }];
    return future;
}

+ (id<FBResponsePayload>)handleScript:(FBRouteRequest *)request
{
  
  NSString *scriptContext = request.arguments[@"context"];
  NSArray <NSString *> *lines = [scriptContext componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  
  
  return FBResponseWithOK();
}

+ (id<FBResponsePayload>)handleKeys:(FBRouteRequest *)request
{
  NSString *textToType = [request.arguments[@"value"] componentsJoinedByString:@""];
  NSUInteger frequency = [request.arguments[@"frequency"] unsignedIntegerValue] ?: [FBConfiguration maxTypingFrequency];
  [KIFTypist enterCharacter:textToType];
  return FBResponseWithOK();
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
