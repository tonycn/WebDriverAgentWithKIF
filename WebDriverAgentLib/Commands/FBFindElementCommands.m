/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBFindElementCommands.h"

#import "FBConfiguration.h"
#import "FBExceptionHandler.h"
#import "FBRouteRequest.h"
#import "FBMacros.h"
#import "FBPredicate.h"
#import "FBSession.h"
#import "FBApplication.h"
#import "UIView+FBHelper.h"


static id<FBResponsePayload> FBNoSuchElementErrorResponseForRequest(FBRouteRequest *request)
{
  NSDictionary *errorDetails = @{
    @"description": @"unable to find an element",
    @"using": request.arguments[@"using"] ?: @"",
    @"value": request.arguments[@"value"] ?: @"",
  };
  return FBResponseWithStatus(FBCommandStatusNoSuchElement, errorDetails);
}

@implementation FBFindElementCommands

#pragma mark - <FBCommandHandler>

+ (NSArray *)routes
{
  return
  @[
    [[FBRoute POST:@"/element"] respondWithTarget:self action:@selector(handleFindElement:)],
    [[FBRoute POST:@"/elements"] respondWithTarget:self action:@selector(handleFindElements:)],
    [[FBRoute POST:@"/element/:uuid/element"] respondWithTarget:self action:@selector(handleFindSubElement:)],
    [[FBRoute POST:@"/element/:uuid/elements"] respondWithTarget:self action:@selector(handleFindSubElements:)],
    [[FBRoute GET:@"/wda/element/:uuid/getVisibleCells"] respondWithTarget:self action:@selector(handleFindVisibleCells:)],
  ];
}


#pragma mark - Commands

+ (id<FBResponsePayload>)handleFindElement:(FBRouteRequest *)request
{
  FBSession *session = request.session;
  UIView *element = [self.class elementUsing:request.arguments[@"using"] withValue:request.arguments[@"value"] under:session.application];
  if (!element) {
    return FBNoSuchElementErrorResponseForRequest(request);
  }
  return FBResponseWithCachedElement(element, request.session.elementCache, FBConfiguration.shouldUseCompactResponses);
}

+ (id<FBResponsePayload>)handleFindElements:(FBRouteRequest *)request
{
  FBSession *session = request.session;
  NSArray *elements = [self.class elementsUsing:request.arguments[@"using"] withValue:request.arguments[@"value"] under:session.application
                    shouldReturnAfterFirstMatch:NO];
  return FBResponseWithCachedElements(elements, request.session.elementCache, FBConfiguration.shouldUseCompactResponses);
}

+ (id<FBResponsePayload>)handleFindVisibleCells:(FBRouteRequest *)request
{
  return nil;
}

+ (id<FBResponsePayload>)handleFindSubElement:(FBRouteRequest *)request
{
//  FBElementCache *elementCache = request.session.elementCache;
//  XCUIElement *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
//  XCUIElement *foundElement = [self.class elementUsing:request.arguments[@"using"] withValue:request.arguments[@"value"] under:element];
//  if (!foundElement) {
//    return FBNoSuchElementErrorResponseForRequest(request);
//  }
//  return FBResponseWithCachedElement(foundElement, request.session.elementCache, FBConfiguration.shouldUseCompactResponses);
    return nil;
}

+ (id<FBResponsePayload>)handleFindSubElements:(FBRouteRequest *)request
{
//  FBElementCache *elementCache = request.session.elementCache;
//  XCUIElement *element = [elementCache elementForUUID:request.parameters[@"uuid"]];
//  NSArray *foundElements = [self.class elementsUsing:request.arguments[@"using"] withValue:request.arguments[@"value"] under:element
//                         shouldReturnAfterFirstMatch:NO];
//
//  return FBResponseWithCachedElements(foundElements, request.session.elementCache, FBConfiguration.shouldUseCompactResponses);
    return nil;
}


#pragma mark - Helpers

+ (UIView *)elementUsing:(NSString *)usingText withValue:(NSString *)value under:(UIView *)element
{
  return [[self elementsUsing:usingText withValue:value under:element shouldReturnAfterFirstMatch:YES] firstObject];
}

+ (NSArray *)elementsUsing:(NSString *)usingText withValue:(NSString *)value under:(UIView *)element shouldReturnAfterFirstMatch:(BOOL)shouldReturnAfterFirstMatch
{
    NSArray *elements;
    const BOOL partialSearch = [usingText isEqualToString:@"partial link text"];
    if (partialSearch || [usingText isEqualToString:@"link text"]) {
        NSArray *components = [value componentsSeparatedByString:@"="];
        NSString *propertyValue = components.lastObject;
        NSString *propertyName = (components.count < 2 ? @"name" : components.firstObject);
        elements = [element fb_descendantsMatchingProperty:propertyName value:propertyValue partialSearch:partialSearch];
    } else if ([usingText isEqualToString:@"class chain"]) {
        elements = [element fb_descendantsMatchingClassChain:value shouldReturnAfterFirstMatch:shouldReturnAfterFirstMatch];
    } else if ([usingText isEqualToString:@"accessibility id"]) {
        elements = [element fb_descendantsMatchingIdentifier:value shouldReturnAfterFirstMatch:shouldReturnAfterFirstMatch];
    } else {
        [[NSException exceptionWithName:FBElementAttributeUnknownException reason:[NSString stringWithFormat:@"Invalid locator requested: %@", usingText] userInfo:nil] raise];
    }
    return elements;
}

@end
