//
//  FBUITextInputCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-27.
//

#import "FBUITextInputCommand.h"
#import <KIF/KIFTypist.h>

@implementation FBUITextInputCommand

- (instancetype)initWithAttributes:(NSDictionary *)attrs {
    self = [super initWithAttributes:attrs];
    if (self) {
        self.text = attrs[@"text"];
        self.interval = [attrs[@"interval"] doubleValue];
        self.interval = self.interval > 0 ?: 0.1;
    }
    return self;
}

- (void)executeOn:(UIView * _Nullable)element
      finishBlock:(void (^)(BOOL))finishBlock
{
    if (element == nil) {
        finishBlock(NO);
    } else {
        [KIFTypist setKeystrokeDelay:self.interval];
    }
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [[super toDictionary] mutableCopy];
    dict[@"text"] = self.text;
    dict[@"interval"] = @(self.interval);
    return dict;
}

+ (NSString *)actionString
{
    return @"input";
}

@end
