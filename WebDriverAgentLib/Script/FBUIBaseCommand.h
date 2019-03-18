//
//  FBUIBaseCommand.h
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBUIBaseCommand : NSObject

@property (nonatomic, strong) NSString *classChain;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *props;

- (BOOL)execute;

- (NSArray <UIView *> *)findElementsByClassChain:(NSString *)classChain
                     shouldReturnAfterFirstMatch:(BOOL)shouldReturnAfterFirstMatch;

@end

NS_ASSUME_NONNULL_END
