//
//  FBUIDismissKeyboardCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-25.
//

#import "FBUIDismissKeyboardCommand.h"

#import "FBApplication.h"

@implementation FBUIDismissKeyboardCommand

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.elementIgnored = YES;
        self.action = [self.class actionString];
    }
    return self;
}

- (void)executeOn:(UIView * _Nullable)element
      finishBlock:(void (^)(BOOL))finishBlock
{
    [[FBApplication fb_activeApplication] dismissKeyboard];
    finishBlock(YES);
}

+ (NSString *)actionString
{
    return @"hideKeyboard";
}

@end
