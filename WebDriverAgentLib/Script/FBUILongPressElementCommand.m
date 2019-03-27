//
//  FBUILongPressElementCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-27.
//

#import "FBUILongPressElementCommand.h"

#import <KIF/UIView-KIFAdditions.h>

@implementation FBUILongPressElementCommand

- (instancetype)initWithAttributes:(NSDictionary *)attrs {
    self = [super initWithAttributes:attrs];
    if (self) {
        self.duration = [attrs[@"duration"] floatValue];
        self.duration = self.duration ?: 3; // default 3 seconds;
    }
    return self;
}

- (void)executeOn:(UIView * _Nullable)element
      finishBlock:(void (^)(BOOL))finishBlock
{
    if (element == nil) {
        finishBlock(NO);
    } else {
        CGPoint elementCenter = CGPointMake(CGRectGetMidX(element.bounds), CGRectGetMidY(element.bounds));
        [element longPressAtPoint:elementCenter duration:self.duration];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((self.duration + 0.1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            finishBlock(YES);
        });
    }
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [[super toDictionary] mutableCopy];
    dict[@"duration"] = @(self.duration);
    return dict;
}

+ (NSString *)actionString
{
    return @"longPress";
}
@end
 
