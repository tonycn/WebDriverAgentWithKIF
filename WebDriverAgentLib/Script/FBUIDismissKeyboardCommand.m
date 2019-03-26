//
//  FBUIDismissKeyboardCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-25.
//

#import "FBUIDismissKeyboardCommand.h"

#import "FBApplication.h"

@implementation FBUIDismissKeyboardCommand

- (instancetype)initWithAttributes:(NSDictionary *)attrs
{
    self = [super initWithAttributes:attrs];
    if (self) {
        self.elementIgnored = YES;
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
