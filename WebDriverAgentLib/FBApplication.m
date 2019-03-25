/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBApplication.h"

#import "FBRunLoopSpinner.h"
#import "FBMacros.h"
#import "UIApplication-KIFAdditions.h"
#import "UIView+FBHelper.h"
#import "UIWindow-KIFAdditions.h"
#import "FBWebDriverServerRunner.h"

@interface FBApplication ()
@property (nonatomic, assign) BOOL fb_isObservingAppImplCurrentProcess;
@end

@implementation FBApplication

+ (instancetype)fb_activeApplication
{
    static dispatch_once_t onceToken;
    static  FBApplication *instance;
    dispatch_once(&onceToken, ^{
        instance = [[FBApplication alloc] init];
    });
  return instance;
}

- (void)launch
{
    [[FBWebDriverServerRunner sharedRunner] startRunner];
}

- (NSString *)bundleID
{
    NSString *bundleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:kCFBundleIdentifierKey];
}

- (NSDictionary *)fb_tree
{
    NSArray <NSString *> *windowsToIgnore = @[@"UITextEffectsWindow", @"UIRemoteKeyboardWindow"];
    NSArray <UIWindow *> *allWindows = UIApplication.sharedApplication.windows;
    NSMutableArray <NSDictionary *> *windows = [NSMutableArray array];
    for (UIWindow *window in allWindows) {
        if ([windowsToIgnore containsObject:NSStringFromClass(window.class)]) {
            continue;
        }
        NSDictionary *viewDict = [UIView fb_dictionaryForView:window];
        [windows addObject:viewDict];
    }
    NSString *screenRect = NSStringFromCGRect(CGRectIntegral([UIScreen.mainScreen bounds]));
    return @{@"children": windows,
             @"rect": [UIView fb_formattedRectWithFrame:[UIScreen.mainScreen bounds]],
             @"isEnabled": @"1",
             @"isVisible": @"1",
             @"frame": screenRect,
             @"type": @"UIScreen"};
}

- (NSArray <UIWindow *> *)fb_windows
{
    return UIApplication.sharedApplication.windows;
}

- (NSArray <UIWindow *> *)fb_reversedWindows
{
  return [UIApplication.sharedApplication.windows sortedArrayUsingComparator:^NSComparisonResult(UIWindow *  _Nonnull obj1, UIWindow *  _Nonnull obj2) {
    return [@(obj2.windowLevel) compare:@(obj1.windowLevel)];
  }];
}

- (UIWindow *)fb_keyWindow
{
    return UIApplication.sharedApplication.keyWindow;
}

- (void)dismissKeyboard
{
  for (UIWindow *window in self.fb_windows) {
    if ([window.firstResponder canResignFirstResponder]) {
      [window.firstResponder resignFirstResponder];
    }
  }
}

- (CGRect)wdFrame
{
    return [UIScreen.mainScreen bounds];
}

- (UIInterfaceOrientation)interfaceOrientation
{
    return UIApplication.sharedApplication.statusBarOrientation;
}

@end
