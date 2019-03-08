/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBResponsePayload.h"

#import "FBResponseFilePayload.h"
#import "FBResponseJSONPayload.h"
#import "FBSession.h"
#import "UIView+FBHelper.h"
#import "FBElementCache.h"


inline static NSDictionary *FBDictionaryResponseWithElement(UIView *element, NSString *elementUUID, BOOL compact);

id<FBResponsePayload> FBResponseWithOK()
{
  return FBResponseWithStatus(FBCommandStatusNoError, nil);
}

id<FBResponsePayload> FBResponseWithObject(id object)
{
  return FBResponseWithStatus(FBCommandStatusNoError, object);
}

id<FBResponsePayload> FBResponseWithCachedElement(UIView *element, FBElementCache *elementCache, BOOL compact)
{
  NSString *elementUUID = [elementCache storeElement:element];
  return FBResponseWithStatus(FBCommandStatusNoError, FBDictionaryResponseWithElement(element, elementUUID, compact));
}

id<FBResponsePayload> FBResponseWithCachedElements(NSArray<UIView *> *elements, FBElementCache *elementCache, BOOL compact)
{
  NSMutableArray *elementsResponse = [NSMutableArray array];
  for (UIView *element in elements) {
    NSString *elementUUID = [elementCache storeElement:element];
    [elementsResponse addObject:FBDictionaryResponseWithElement(element, elementUUID, compact)];
  }
  return FBResponseWithStatus(FBCommandStatusNoError, elementsResponse);
}

id<FBResponsePayload> FBResponseWithElementUUID(NSString *elementUUID)
{
  return [[FBResponseJSONPayload alloc] initWithDictionary:@{
    @"id" : elementUUID,
    @"sessionId" : [FBSession activeSession].identifier ?: NSNull.null,
    @"value" : @"",
    @"status" : @0,
  }];
}

id<FBResponsePayload> FBResponseWithError(NSError *error)
{
  return FBResponseWithStatus(FBCommandStatusUnhandled, error.description);
}

id<FBResponsePayload> FBResponseWithErrorFormat(NSString *format, ...)
{
  va_list argList;
  va_start(argList, format);
  NSString *errorMessage = [[NSString alloc] initWithFormat:format arguments:argList];
  id<FBResponsePayload> payload = FBResponseWithStatus(FBCommandStatusUnhandled, errorMessage);
  va_end(argList);
  return payload;
}

id<FBResponsePayload> FBResponseWithStatus(FBCommandStatus status, id object)
{
  return [[FBResponseJSONPayload alloc] initWithDictionary:@{
    @"value" : object ?: @{},
    @"sessionId" : [FBSession activeSession].identifier ?: NSNull.null,
    @"status" : @(status),
  }];
}

id<FBResponsePayload> FBResponseFileWithPath(NSString *path)
{
  return [[FBResponseFilePayload alloc] initWithFilePath:path];
}

inline static NSDictionary *FBDictionaryResponseWithElement(UIView *element, NSString *elementUUID, BOOL compact)
{
  return [UIView fb_dictionaryForView:element];
}
