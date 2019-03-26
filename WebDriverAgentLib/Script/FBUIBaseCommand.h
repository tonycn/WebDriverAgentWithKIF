//
//  FBUIBaseCommand.h
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-18.
//

#import <Foundation/Foundation.h>


extern NSString * FBUICommandErrorDomain;
extern NSString * FBUICommandErrorInfoKeyReason;

NS_ASSUME_NONNULL_BEGIN

@interface FBUIBaseCommand : NSObject

@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong, nullable) NSString *path; // classChain
//@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic, strong, nullable) NSDictionary *originCommandDict;

@property (nonatomic) BOOL elementIgnored;
           
// Step 1
- (void)waitUntilElement:(void (^)(UIView * _Nullable element ))resultBlock;

// Step 2
- (void)executeOn:(UIView * _Nullable)element
      finishBlock:(void (^)(BOOL))finishBlock;

- (void)executeWithResultBlock:(void (^)(BOOL succ, UIView * _Nullable element))resultBlock;

- (instancetype)initWithAttributes:(NSDictionary *)attrs;

#pragma mark -
- (NSDictionary *)toDictionary;

- (NSDictionary *)toResponsePayloadObject;

- (void)reducePathIfPossibleForElement:(UIView *)element;

- (NSError *)commandError;

+ (NSArray <UIView *> *)findElementsByClassChain:(NSString *)classChain
                     shouldReturnAfterFirstMatch:(BOOL)shouldReturnAfterFirstMatch;

+ (void)findElementByClassChain:(NSString *)classChain
    shouldReturnAfterFirstMatch:(BOOL)shouldReturnAfterFirstMatch
                        timeout:(NSTimeInterval)timeout
                elementsDidFind:(void (^)(NSArray <UIView *> * _Nullable))elementsDidFind;

+ (NSString *)actionString;

@end

NS_ASSUME_NONNULL_END
