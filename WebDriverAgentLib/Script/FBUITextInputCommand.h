//
//  FBUITextInputCommand.h
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-27.
//

#import "FBUIBaseCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBUITextInputCommand : FBUIBaseCommand
@property (nonatomic, strong) NSString *text;
@property (nonatomic) NSTimeInterval interval;
@end

NS_ASSUME_NONNULL_END
