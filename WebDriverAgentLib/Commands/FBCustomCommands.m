/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBCustomCommands.h"

#import "FBApplication.h"
#import "FBConfiguration.h"
#import "FBExceptionHandler.h"
#import "FBKeyboard.h"
#import "FBResponsePayload.h"
#import "FBRoute.h"
#import "FBRouteRequest.h"
#import "FBRunLoopSpinner.h"
#import "FBSession.h"
#import "KIFTypist.h"
#import "UIWindow-KIFAdditions.h"
#import "FBElementCache.h"
#import "FBUITestScript.h"
#import "FBResponseFuturePayload.h"

@implementation FBCustomCommands

+ (NSArray *)routes
{
  return
  @[
    [[FBRoute POST:@"/timeouts"] respondWithTarget:self action:@selector(handleTimeouts:)],
    [[FBRoute POST:@"/wda/homescreen"].withoutSession respondWithTarget:self action:@selector(handleHomescreenCommand:)],
    [[FBRoute POST:@"/wda/deactivateApp"] respondWithTarget:self action:@selector(handleDeactivateAppCommand:)],
    [[FBRoute GET:@"/wda/elementCache/size"] respondWithTarget:self action:@selector(handleGetElementCacheSizeCommand:)],
    [[FBRoute POST:@"/wda/elementCache/clear"] respondWithTarget:self action:@selector(handleClearElementCacheCommand:)],
    [[FBRoute POST:@"/script"] respondWithTarget:self action:@selector(handleScriptCommand:)],

  ];
}


#pragma mark - Commands

+ (id<FBResponsePayload>)handleHomescreenCommand:(FBRouteRequest *)request
{
  return FBResponseWithOK();
}

+ (id<FBResponsePayload>)handleDeactivateAppCommand:(FBRouteRequest *)request
{
  return FBResponseWithOK();
}

+ (id<FBResponsePayload>)handleTimeouts:(FBRouteRequest *)request
{
  // This method is intentionally not supported.
  return FBResponseWithOK();
}

+ (id<FBResponsePayload>)handleDismissKeyboardCommand:(FBRouteRequest *)request
{
  [request.session.application dismissKeyboard];
  return FBResponseWithOK();
}

+ (id<FBResponsePayload>)handleGetElementCacheSizeCommand:(FBRouteRequest *)request
{
  NSNumber *count = [NSNumber numberWithUnsignedInteger:[request.session.elementCache count]];
  return FBResponseWithObject(count);
}

+ (id<FBResponsePayload>)handleClearElementCacheCommand:(FBRouteRequest *)request
{
  
  FBElementCache *elementCache = request.session.elementCache;
  [elementCache clear];
  return FBResponseWithOK();
}

+ (id<FBResponsePayload>)handleScriptCommand:(FBRouteRequest *)request
{
    NSString *scriptContent = request.arguments[@"script"];
    FBUITestScript *script = [FBUITestScript scriptByCommandLines:scriptContent];
    
    FBResponseFuturePayload *future = [[FBResponseFuturePayload alloc] init];
    [script executeDidFinish:^(BOOL succ, NSError * _Nonnull error) {
        [future fillRealResponsePayload:FBResponseWithOK()];
    }];
    return future;
}

@end
