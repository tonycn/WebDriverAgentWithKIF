//
//  UIView+FBHelper.h
//  WebDriverAgent
//
//  Created by jianjun on 2019-02-22.
//

#import <UIKit/UIKit.h>

@class FBClassChainItem;

NS_ASSUME_NONNULL_BEGIN

@interface UIView (FBHelper)

+ (NSDictionary *)fb_dictionaryForView:(UIView *)view;

+ (NSDictionary *)fb_formattedRectWithFrame:(CGRect)frame;

- (NSArray<UIView *> *)fb_descendantsMatchingProperty:(NSString *)property
                                                value:(NSString *)value
                                        partialSearch:(BOOL)partialSearch;

- (NSArray<UIView *> *)fb_descendantsMatchingClassChain:(NSString *)classChainPath
                            shouldReturnAfterFirstMatch:(BOOL)shouldReturnAfterFirstMatch;

- (NSArray<UIView *> *)fb_descendantsMatchingIdentifier:(NSString *)viewIdentifier
                            shouldReturnAfterFirstMatch:(BOOL)shouldReturnAfterFirstMatch;

- (BOOL)matchClassChainItem:(FBClassChainItem *)classChainItem;

- (NSString *)fb_generateElementQuery;

- (NSString *)fb_generateElementClassChain;

- (NSString *)fb_generateElementReducedClassChainByMaxLevel:(NSInteger)level;

- (NSString *)fb_uuid;

- (NSString *)fb_label;

// window frame
- (CGRect)wdFrame;

// window frame rect dictionary
- (NSDictionary *)wdRect;

- (BOOL)fb_checkIfEnabled;

- (BOOL)fb_clearTextWithError:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
