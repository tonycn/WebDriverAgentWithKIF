//
//  FBUIScrollCommand.h
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-25.
//

#import "FBUIBaseCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBUIScrollCommand : FBUIBaseCommand
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic, strong) NSString *until;
@end

NS_ASSUME_NONNULL_END
