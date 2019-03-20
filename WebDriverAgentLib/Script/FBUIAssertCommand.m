//
//  FBUIAssertCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-18.
//

#import "FBUIAssertCommand.h"

@implementation FBUIAssertCommand

- (BOOL)executeOn:(UIView *)element
{
  return element != nil;
}

+ (NSString *)actionString
{
    return @"assert";
}

@end
