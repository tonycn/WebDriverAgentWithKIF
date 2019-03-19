//
//  FBUIAssertCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-18.
//

#import "FBUIAssertCommand.h"

@implementation FBUIAssertCommand

- (void)executeWithResultBlock:(void (^)(BOOL))resultBlock
{
    [self.class findElementByClassChain:self.classChain shouldReturnAfterFirstMatch:YES timeout:self.timeout elementsDidFind:^(NSArray<UIView *> * _Nonnull elements) {
        UIView *element = elements.firstObject;
        if (element) {
            resultBlock(YES);
        } else {
            resultBlock(NO);
        }
    }];
}

@end
