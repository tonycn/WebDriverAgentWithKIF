//
//  UIView+FBHelper.h
//  WebDriverAgent
//
//  Created by jianjun on 2019-02-22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (FBHelper)

+ (NSDictionary *)fb_dictionaryForView:(UIView *)view;

+ (NSDictionary *)fb_formattedRectWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
