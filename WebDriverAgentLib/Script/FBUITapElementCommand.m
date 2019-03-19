//
//  FBUITapCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-18.
//

#import "FBUITapElementCommand.h"

#import "FBSession.h"
#import "FBApplication.h"
#import "FBResponsePayload.h"
#import "FBElementCache.h"
#import "UIView-KIFAdditions.h"
#import "UIView+FBHelper.h"

@implementation FBUITapElementCommand

- (void)executeWithResultBlock:(void (^)(BOOL))resultBlock
{
    [self.class findElementByClassChain:self.classChain shouldReturnAfterFirstMatch:YES timeout:self.timeout elementsDidFind:^(NSArray<UIView *> * _Nonnull elements) {
        UIView *element = elements.firstObject;
        if (element) {
            [element tap];
            resultBlock(YES);
        } else {
            resultBlock(NO);
        }
    }];
}

+ (NSString *)actionString
{
    return @"tap";
}

@end
