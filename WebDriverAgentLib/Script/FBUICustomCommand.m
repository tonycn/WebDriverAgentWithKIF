//
//  FBUICustomCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-27.
//

#import "FBUICustomCommand.h"

static NSMutableDictionary *gHandlers;

@implementation FBUICustomCommand

- (instancetype)initWithAttributes:(NSDictionary *)attrs {
    self = [super initWithAttributes:attrs];
    if (self) {
        self.elementIgnored = YES;
        self.handler = attrs[@"handler"];
        self.params = attrs[@"params"];
    }
    return self;
}

- (void)executeOn:(UIView * _Nullable)element
      finishBlock:(void (^)(BOOL))finishBlock
{
    fbui_hanlder_action_block actionBlock = [gHandlers objectForKey:self.handler];
    if (actionBlock) {
        actionBlock(self.params, ^(BOOL succ) {
            finishBlock(succ);
        });
    } else {
        finishBlock(NO);
    }
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dict = [[super toDictionary] mutableCopy];
    dict[@"params"] = self.params;
    dict[@"handler"] = self.handler;
    return dict;
}

+ (NSString *)actionString
{
    return @"custom";
}

+ (void)registerHandlerByName:(NSString *)name
                  actionBlock:(fbui_hanlder_action_block)actionBlock
{
    if (gHandlers == nil) {
        gHandlers = [[NSMutableDictionary alloc] init];
    }
    [gHandlers setObject:[actionBlock copy] forKey:name];
}

@end
