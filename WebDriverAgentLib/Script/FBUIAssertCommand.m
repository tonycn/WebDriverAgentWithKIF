//
//  FBUIAssertCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-18.
//

#import "FBUIAssertCommand.h"

@implementation FBUIAssertCommand

- (void)executeOn:(UIView * _Nullable)element
      finishBlock:(void (^)(BOOL))finishBlock
{
  finishBlock(element != nil);
}

+ (NSString *)actionString
{
    return @"assert";
}

@end
