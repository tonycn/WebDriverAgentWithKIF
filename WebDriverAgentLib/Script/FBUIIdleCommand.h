//
//  FBUIIdleCommand.h
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-27.
//

#import "FBUIBaseCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBUIIdleCommand : FBUIBaseCommand
@property (nonatomic) NSTimeInterval duration;
@end

NS_ASSUME_NONNULL_END
