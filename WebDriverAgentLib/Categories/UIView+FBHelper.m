//
//  UIView+FBHelper.m
//  WebDriverAgent
//
//  Created by jianjun on 2019-02-22.
//

#import "UIView+FBHelper.h"

@implementation UIView (FBHelper)

- (NSString *)fb_viewLabel
{
    if ([self isKindOfClass:UILabel.class]) {
        return ((UILabel *)self).text;
    } else if ([self isKindOfClass:UIButton.class]) {
        return [((UIButton *)self) titleForState:UIControlStateNormal];
    } else {
        return @"";
    }
}

+ (NSDictionary *)fb_dictionaryForView:(UIView *)view
{
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    info[@"type"] = NSStringFromClass(view.class);
    info[@"name"] = nil;
    info[@"value"] = nil;
    info[@"label"] = [view fb_viewLabel];
    info[@"rect"] =  [self fb_formattedRectWithFrame:view.frame];
    info[@"frame"] = NSStringFromCGRect(CGRectIntegral(view.frame));
    info[@"isEnabled"] = [@([view fb_checkIfEnabled]) stringValue];
    info[@"isVisible"] = [@(![view isHidden]) stringValue];
    
    NSArray <UIView *> *childElements = view.subviews;
    if ([childElements count]) {
        info[@"children"] = [[NSMutableArray alloc] init];
        for (UIView *childView in childElements) {
            [info[@"children"] addObject:[self fb_dictionaryForView:childView]];
        }
    }
    return info;
}

+ (NSDictionary *)fb_formattedRectWithFrame:(CGRect)frame
{
    frame = CGRectIntegral(frame);
    return @{
             @"x": @(isinf(CGRectGetMinX(frame)) ? 0: CGRectGetMinX(frame)),
             @"y": @(isinf(CGRectGetMinY(frame)) ? 0: CGRectGetMinY(frame)),
             @"width": @(isinf(CGRectGetWidth(frame)) ? 0 : CGRectGetWidth(frame)),
             @"height": @(isinf(CGRectGetHeight(frame)) ? 0 : CGRectGetHeight(frame)),
             };
}


- (BOOL)fb_checkIfEnabled
{
    UIControl *control = nil;
    if ([self isKindOfClass:[UIControl class]]) {
        control = (UIControl *)self;
    }
    return self.userInteractionEnabled && (control == nil ?: control.isEnabled);
}


@end
