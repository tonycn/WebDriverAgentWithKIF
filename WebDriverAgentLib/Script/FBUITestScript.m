//
//  FBUITestScript.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-18.
//

#import "FBUITestScript.h"

#import "FBUIAssertCommand.h"
#import "FBUITapElementCommand.h"

@implementation FBUITestScript

+ (FBUITestScript *)scriptByContent:(NSString *)scriptContent
{
  NSData *jsonData = [scriptContent dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
  FBUITestScript *script = [[FBUITestScript alloc] init];
  script.scriptID = jsonDict[@"scriptID"];
  script.name = jsonDict[@"name"];
  NSArray <NSString *> * commandDictArr = jsonDict[@"commands"];
  NSMutableArray <FBUIBaseCommand *> *commands = [NSMutableArray arrayWithCapacity:commandDictArr.count];
  for (NSDictionary *commandDict in commandDictArr) {
    [commands addObject:[self generateCommandBy:commandDict]];
  }
  script.commands = commands;
  return script;
}

+ (FBUIBaseCommand * _Nonnull)generateCommandBy:(NSDictionary * _Nonnull)commandDict
{
  NSString *actionStr = commandDict[@"action"];
  FBUIBaseCommand *command = nil;
  if ([actionStr isEqualToString:[FBUITapElementCommand actionString]]) {
    command = [[FBUITapElementCommand alloc] init];
  } else if ([actionStr isEqualToString:[FBUIAssertCommand actionString]]) {
    command = [[FBUIAssertCommand alloc] init];
  } else {
    // Not supported
    command = [[FBUIBaseCommand alloc] init];
  }
  command.action = actionStr;
  // 兼容 path 和 classChain
  command.path = commandDict[@"path"];
  command.props = commandDict[@"props"];
  if (commandDict[@"timeout"]) {
    command.timeout = [commandDict[@"timeout"] doubleValue];
  }
  command.originCommandDict = commandDict;
  return command;
}

+ (FBUIBaseCommand * _Nonnull)generateCommandByAction:(NSString *)action
                                           classChain:(NSString *)classChain
{
  return [self generateCommandBy:@{@"action": action?:@"", @"path": classChain?:@""}];
}

- (void)executeDidFinish:(void (^)(BOOL succ, NSError *error))resultBlock
{
  [self executeCommands:self.commands didFinish:resultBlock];
}

- (void)executeCommands:(NSArray *)commands
              didFinish:(void (^)(BOOL succ, NSError * _Nullable error))resultBlock
{
  if (commands.count == 0) {
    resultBlock(NO, nil);
  }
  FBUIBaseCommand *cmd = [commands firstObject];
  [cmd executeWithResultBlock:^(BOOL succ, UIView *element) {
    if (succ) {
      if (commands.count == 1) {
        resultBlock(YES, [cmd commandError]);
      } else {
        NSArray *remainsArr = [commands subarrayWithRange:NSMakeRange(1, commands.count-1)];
        [self executeCommands:remainsArr
                    didFinish:resultBlock];
      }
    } else {
      resultBlock(NO, [cmd commandError]);
    }
  }];
}

@end
