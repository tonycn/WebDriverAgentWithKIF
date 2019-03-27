//
//  FBUICustomCommand.h
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-27.
//

#import "FBUIBaseCommand.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^fbui_finish_block)(BOOL succ);
typedef void (^fbui_hanlder_action_block)(NSString *params, fbui_finish_block);

@interface FBUICustomCommand : FBUIBaseCommand
@property (nonatomic, strong) NSString *handler;
@property (nonatomic, strong) NSString *params;

+ (void)registerHandlerByName:(NSString *)name
                  actionBlock:(fbui_hanlder_action_block)actionBlock;

@end

NS_ASSUME_NONNULL_END
