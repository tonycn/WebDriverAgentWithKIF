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
//    [[FBRoute GET:@"/element/:uuid/enabled"] respondWithTarget:self action:@selector(handleGetEnabled:)],
    [[FBRoute GET:@"/element/:uuid/rect"] respondWithTarget:self action:@selector(handleGetRect:)],
//    [[FBRoute GET:@"/element/:uuid/attribute/:name"] respondWithTarget:self action:@selector(handleGetAttribute:)],
//    [[FBRoute GET:@"/element/:uuid/text"] respondWithTarget:self action:@selector(handleGetText:)],
//    [[FBRoute GET:@"/element/:uuid/displayed"] respondWithTarget:self action:@selector(handleGetDisplayed:)],
//    [[FBRoute GET:@"/element/:uuid/name"] respondWithTarget:self action:@selector(handleGetName:)],
//    [[FBRoute POST:@"/element/:uuid/value"] respondWithTarget:self action:@selector(handleSetValue:)],
    [[FBRoute POST:@"/element/:uuid/click"] respondWithTarget:self action:@selector(handleClick:)],
    [[FBRoute POST:@"/element/:uuid/clear"] respondWithTarget:self action:@selector(handleClear:)],
    [[FBRoute GET:@"/element/:uuid/screenshot"] respondWithTarget:self action:@selector(handleElementScreenshot:)],
//    [[FBRoute GET:@"/wda/element/:uuid/accessible"] respondWithTarget:self action:@selector(handleGetAccessible:)],
//    [[FBRoute GET:@"/wda/element/:uuid/accessibilityContainer"] respondWithTarget:self action:@selector(handleGetIsAccessibilityContainer:)],
//    [[FBRoute POST:@"/wda/element/:uuid/swipe"] respondWithTarget:self action:@selector(handleSwipe:)],
//    [[FBRoute POST:@"/wda/element/:uuid/pinch"] respondWithTarget:self action:@selector(handlePinch:)],
//    [[FBRoute POST:@"/wda/element/:uuid/doubleTap"] respondWithTarget:self action:@selector(handleDoubleTap:)],
//    [[FBRoute POST:@"/wda/element/:uuid/twoFingerTap"] respondWithTarget:self action:@selector(handleTwoFingerTap:)],
//    [[FBRoute POST:@"/wda/element/:uuid/touchAndHold"] respondWithTarget:self action:@selector(handleTouchAndHold:)],
    [[FBRoute POST:@"/wda/element/:uuid/scroll"] respondWithTarget:self action:@selector(handleScroll:)],
    [[FBRoute POST:@"/wda/element/:uuid/dragfromtoforduration"] respondWithTarget:self action:@selector(handleDrag:)],
    [[FBRoute POST:@"/wda/dragfromtoforduration"] respondWithTarget:self action:@selector(handleDragCoordinate:)],
    [[FBRoute POST:@"/wda/tap/:uuid"] respondWithTarget:self action:@selector(handleTap:)],
//    [[FBRoute POST:@"/wda/touchAndHold"] respondWithTarget:self action:@selector(handleTouchAndHoldCoordinate:)],
//    [[FBRoute POST:@"/wda/doubleTap"] respondWithTarget:self action:@selector(handleDoubleTapCoordinate:)],
    [[FBRoute POST:@"/wda/keys"] respondWithTarget:self action:@selector(handleKeys:)],
//    [[FBRoute POST:@"/wda/pickerwheel/:uuid/select"] respondWithTarget:self action:@selector(handleWheelSelect:)],
//    [[FBRoute POST:@"/wda/element/forceTouch/:uuid"] respondWithTarget:self action:@selector(handleForceTouch:)],
//    [[FBRoute POST:@"/wda/element/forceTouchByCoordinate/:uuid"] respondWithTarget:self action:@selector(handleForceTouchByCoordinateOnElement:)]
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

//+ (id<FBResponsePayload>)handleGetAttribute:(FBRouteRequest *)request
//{
//  FBElementCache *elementCache = request.session.elementCache;
//  XCUIElement *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
//  id attributeValue = [element fb_valueForWDAttributeName:request.parameters[@"name"]];
//  attributeValue = attributeValue ?: [NSNull null];
//  return FBResponseWithStatus(FBCommandStatusNoError, attributeValue);
//}
//
//+ (id<FBResponsePayload>)handleGetText:(FBRouteRequest *)request
//{
//  FBElementCache *elementCache = request.session.elementCache;
//  XCUIElement *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
//  id text = FBFirstNonEmptyValue(element.wdValue, element.wdLabel);
//  text = text ?: [NSNull null];
//  return FBResponseWithStatus(FBCommandStatusNoError, text);
//}
//
//+ (id<FBResponsePayload>)handleGetDisplayed:(FBRouteRequest *)request
//{
//  FBElementCache *elementCache = request.session.elementCache;
//  XCUIElement *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
//  BOOL isVisible = element.isWDVisible;
//  return FBResponseWithStatus(FBCommandStatusNoError, isVisible ? @YES : @NO);
//}
//
//+ (id<FBResponsePayload>)handleGetAccessible:(FBRouteRequest *)request
//{
//  FBElementCache *elementCache = request.session.elementCache;
//  XCUIElement *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
//  return FBResponseWithStatus(FBCommandStatusNoError, @(element.isWDAccessible));
//}
//
//+ (id<FBResponsePayload>)handleGetIsAccessibilityContainer:(FBRouteRequest *)request
//{
//  FBElementCache *elementCache = request.session.elementCache;
//  XCUIElement *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
//  return FBResponseWithStatus(FBCommandStatusNoError, @(element.isWDAccessibilityContainer));
//}
//
//+ (id<FBResponsePayload>)handleGetName:(FBRouteRequest *)request
//{
//  FBElementCache *elementCache = request.session.elementCache;
//  XCUIElement *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
//  id type = [element wdType];
//  return FBResponseWithStatus(FBCommandStatusNoError, type);
//}
//
//+ (id<FBResponsePayload>)handleSetValue:(FBRouteRequest *)request
//{
//  return FBResponseWithElementUUID(elementUUID);
//}
//
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

//+ (id<FBResponsePayload>)handleDoubleTapCoordinate:(FBRouteRequest *)request
//{
//  CGPoint doubleTapPoint = CGPointMake((CGFloat)[request.arguments[@"x"] doubleValue], (CGFloat)[request.arguments[@"y"] doubleValue]);
//  XCUICoordinate *doubleTapCoordinate = [self.class gestureCoordinateWithCoordinate:doubleTapPoint application:request.session.application shouldApplyOrientationWorkaround:isSDKVersionLessThan(@"11.0")];
//  [doubleTapCoordinate doubleTap];
//  return FBResponseWithOK();
//}
//
//+ (id<FBResponsePayload>)handleTwoFingerTap:(FBRouteRequest *)request
//{
//    FBElementCache *elementCache = request.session.elementCache;
//    XCUIElement *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
//    [element twoFingerTap];
//    return FBResponseWithOK();
//}
//
//+ (id<FBResponsePayload>)handleTouchAndHold:(FBRouteRequest *)request
//{
//  FBElementCache *elementCache = request.session.elementCache;
//  XCUIElement *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
//  [element pressForDuration:[request.arguments[@"duration"] doubleValue]];
//  return FBResponseWithOK();
//}
//
//+ (id<FBResponsePayload>)handleTouchAndHoldCoordinate:(FBRouteRequest *)request
//{
//  CGPoint touchPoint = CGPointMake((CGFloat)[request.arguments[@"x"] doubleValue], (CGFloat)[request.arguments[@"y"] doubleValue]);
//  XCUICoordinate *pressCoordinate = [self.class gestureCoordinateWithCoordinate:touchPoint application:request.session.application shouldApplyOrientationWorkaround:isSDKVersionLessThan(@"11.0")];
//  [pressCoordinate pressForDuration:[request.arguments[@"duration"] doubleValue]];
//  return FBResponseWithOK();
//}
//
//+ (id<FBResponsePayload>)handleForceTouch:(FBRouteRequest *)request
//{
//  FBElementCache *elementCache = request.session.elementCache;
//  XCUIElement *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
//  double pressure = [request.arguments[@"pressure"] doubleValue];
//  double duration = [request.arguments[@"duration"] doubleValue];
//  NSError *error = nil;
//  if (![element fb_forceTouchWithPressure:pressure duration:duration error:&error]) {
//    return FBResponseWithError(error);
//  }
//  return FBResponseWithOK();
//}
//
//+ (id<FBResponsePayload>)handleForceTouchByCoordinateOnElement:(FBRouteRequest *)request
//{
//  FBElementCache *elementCache = request.session.elementCache;
//  XCUIElement *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
//  double pressure = [request.arguments[@"pressure"] doubleValue];
//  double duration = [request.arguments[@"duration"] doubleValue];
//  CGPoint forceTouchPoint = CGPointMake((CGFloat)[request.arguments[@"x"] doubleValue], (CGFloat)[request.arguments[@"y"] doubleValue]);
//  NSError *error = nil;
//  if (![element fb_forceTouchCoordinate:forceTouchPoint pressure:pressure duration:duration error:&error]) {
//    return FBResponseWithError(error);
//  }
//  return FBResponseWithOK();
//}
//
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
    [request.session.application.fb_keyWindow tapAtPoint:tapPoint];
  } else {
    [element tapAtPoint:tapPoint];
  }
  return FBResponseWithOK();
}

//+ (id<FBResponsePayload>)handlePinch:(FBRouteRequest *)request
//{
//  FBElementCache *elementCache = request.session.elementCache;
//  XCUIElement *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
//  CGFloat scale = (CGFloat)[request.arguments[@"scale"] doubleValue];
//  CGFloat velocity = (CGFloat)[request.arguments[@"velocity"] doubleValue];
//  [element pinchWithScale:scale velocity:velocity];
//  return FBResponseWithOK();
//}
//
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
//
//+ (id<FBResponsePayload>)handleElementScreenshot:(FBRouteRequest *)request
//{
//  FBElementCache *elementCache = request.session.elementCache;
//  XCUIElement *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
//  NSError *error;
//  NSData *screenshotData = [element fb_screenshotWithError:&error];
//  if (nil == screenshotData) {
//    return FBResponseWithError(error);
//  }
//  NSString *screenshot = [screenshotData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//  return FBResponseWithObject(screenshot);
//}
//
//static const CGFloat DEFAULT_OFFSET = (CGFloat)0.2;
//
//+ (id<FBResponsePayload>)handleWheelSelect:(FBRouteRequest *)request
//{
//  return FBResponseWithOK();
//}
//
//#pragma mark - Helpers
//
//+ (id<FBResponsePayload>)handleScrollElementToVisible:(XCUIElement *)element withRequest:(FBRouteRequest *)request
//{
//  NSError *error;
//  if (!element.exists) {
//    return FBResponseWithErrorFormat(@"Can't scroll to element that does not exist");
//  }
//  if (![element fb_scrollToVisibleWithError:&error]) {
//    return FBResponseWithError(error);
//  }
//  return FBResponseWithOK();
//}
//
///**
// Returns gesture coordinate for the application based on absolute coordinate
//
// @param coordinate absolute screen coordinates
// @param application the instance of current application under test
// @shouldApplyOrientationWorkaround whether to apply orientation workaround. This is to
// handle XCTest bug where it does not translate screen coordinates for elements if
// screen orientation is different from the default one (which is portrait).
// Different iOS version have different behavior, for example iOS 9.3 returns correct
// coordinates for elements in landscape, but iOS 10.0+ returns inverted coordinates as if
// the current screen orientation would be portrait.
// @return translated gesture coordinates ready to be passed to XCUICoordinate methods
// */
//+ (XCUICoordinate *)gestureCoordinateWithCoordinate:(CGPoint)coordinate application:(XCUIApplication *)application shouldApplyOrientationWorkaround:(BOOL)shouldApplyOrientationWorkaround
//{
//  CGPoint point = coordinate;
//  if (shouldApplyOrientationWorkaround) {
//    point = FBInvertPointForApplication(coordinate, application.frame.size, application.interfaceOrientation);
//  }
//
//  /**
//   If SDK >= 11, the tap coordinate based on application is not correct when
//   the application orientation is landscape and
//   tapX > application portrait width or tapY > application portrait height.
//   Pass the window element to the method [FBElementCommands gestureCoordinateWithCoordinate:element:]
//   will resolve the problem.
//   More details about the bug, please see the following issues:
//   #705: https://github.com/facebook/WebDriverAgent/issues/705
//   #798: https://github.com/facebook/WebDriverAgent/issues/798
//   #856: https://github.com/facebook/WebDriverAgent/issues/856
//   Notice: On iOS 10, if the application is not launched by wda, no elements will be found.
//   See issue #732: https://github.com/facebook/WebDriverAgent/issues/732
//   */
//  XCUIElement *element = application;
//  if (isSDKVersionGreaterThanOrEqualTo(@"11.0")) {
//    XCUIElement *window = application.windows.fb_firstMatch;
//    if (window) {
//      element = window;
//      point.x -= element.frame.origin.x;
//      point.y -= element.frame.origin.y;
//    }
//  }
//  return [self gestureCoordinateWithCoordinate:point element:element];
//}
//
///**
// Returns gesture coordinate based on the specified element.
//
// @param coordinate absolute coordinates based on the element
// @param element the element in the current application under test
// @return translated gesture coordinates ready to be passed to XCUICoordinate methods
// */
//+ (XCUICoordinate *)gestureCoordinateWithCoordinate:(CGPoint)coordinate element:(XCUIElement *)element
//{
//  XCUICoordinate *appCoordinate = [[XCUICoordinate alloc] initWithElement:element normalizedOffset:CGVectorMake(0, 0)];
//  return [[XCUICoordinate alloc] initWithCoordinate:appCoordinate pointsOffset:CGVectorMake(coordinate.x, coordinate.y)];
//}

@end
