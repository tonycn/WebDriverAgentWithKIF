//
//  FBUIIdleCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-27.
//

#import "FBUIIdleCommand.h"

@implementation FBUIIdleCommand

- (instancetype)initWithAttributes:(NSDictionary *)attrs {
    self = [super initWithAttributes:attrs];
    if (self) {
        self.elementIgnored = YES;
        self.duration = [attrs[@"duration"] floatValue];
        self.duration = self.duration ?: 3; // default 3 seconds;
    }
    return self;
}

- (void)executeOn:(UIView * _Nullable)element
      finishBlock:(void (^)(BOOL))finishBlock
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((self.duration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        finishBlock(YES);
    });
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [[super toDictionary] mutableCopy];
    dict[@"duration"] = @(self.duration);
    return dict;
}

+ (NSString *)actionString
{
    return @"idle";
}

@end
