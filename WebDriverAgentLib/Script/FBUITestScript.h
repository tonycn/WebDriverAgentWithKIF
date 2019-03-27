//
//  FBUITestScript.h
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-18.
//

#import <Foundation/Foundation.h>

#import "FBUIBaseCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBUITestScript : NSObject

@property (nonatomic, strong) NSString *scriptID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray <FBUIBaseCommand *> *commands;

+ (FBUITestScript *)scriptByContent:(NSString *)scriptContent;
+ (FBUITestScript *)scriptByCommandLines:(NSString *)commandLines;

+ (FBUIBaseCommand * _Nonnull)generateCommandByAction:(NSString *)action
                                                props:(NSDictionary *)props;

- (void)executeDidFinish:(void (^)(BOOL succ, NSError *error))resultBlock;

@end

NS_ASSUME_NONNULL_END
