/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBElementCache.h"

#import "UIView+FBHelper.h"

@interface FBElementCacheItem : NSObject
@property (nonatomic, weak) UIView *element;
@end


@implementation FBElementCacheItem
- (instancetype)initWithElement:(UIView *)view
{
    self = [super init];
    if (self) {
        self.element = view;
    }
    return self;
}
@end


@interface FBElementCache ()
@property (atomic, strong) NSMutableDictionary <NSString *, FBElementCacheItem *> *elementCache;
@end

@implementation FBElementCache

- (instancetype)init
{
  self = [super init];
  if (!self) {
    return nil;
  }
  _elementCache = [[NSMutableDictionary alloc] init];
  return self;
}

- (NSString *)storeElement:(UIView *)element
{
  NSString *uuid = [element fb_uuid];
  self.elementCache[uuid] = element;
  return uuid;
}

- (UIView *)elementForUUID:(NSString *)uuid
{
  if (!uuid) {
    return nil;
  }
  UIView *element = self.elementCache[uuid];
  return element;
}

- (void)clear
{
  [self.elementCache removeAllObjects];
}

- (NSUInteger)count
{
  return [self.elementCache count];
}
@end
