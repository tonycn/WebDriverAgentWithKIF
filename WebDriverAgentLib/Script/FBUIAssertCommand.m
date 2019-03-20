//
//  FBUIAssertCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-18.
//

#import "FBUIAssertCommand.h"

@implementation FBUIAssertCommand

- (void)executeWithResultBlock:(void (^)(BOOL succ, UIView *element))resultBlock
{
    [self.class findElementByClassChain:self.path shouldReturnAfterFirstMatch:YES timeout:self.timeout elementsDidFind:^(NSArray<UIView *> * _Nonnull elements) {
        UIView *element = elements.firstObject;
        if (element) {
            resultBlock(YES, element);
        } else {
            resultBlock(NO, element);
        }
    }];
}

+ (NSString *)actionString
{
    return @"assert";
}

@end
