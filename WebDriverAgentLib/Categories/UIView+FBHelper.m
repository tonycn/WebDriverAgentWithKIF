//
//  UIView+FBHelper.m
//  WebDriverAgent
//
//  Created by jianjun on 2019-02-22.
//

#import "UIView+FBHelper.h"

#import "FBClassChainQueryParser.h"

@implementation UIView (FBHelper)

+ (NSDictionary *)fb_dictionaryForView:(UIView *)view
{
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    info[@"type"] = NSStringFromClass(view.class);
    info[@"name"] = nil;
    info[@"value"] = nil;
    info[@"label"] = [view fb_label];
    info[@"path"] = nil;
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

- (NSArray<UIView *> *)fb_descendantsMatchingProperty:(NSString *)property
                                                value:(NSString *)value
                                        partialSearch:(BOOL)partialSearch
{
    return nil;
}

- (NSArray<UIView *> *)fb_descendantsMatchingClassChain:(NSString *)classChainPath
                            shouldReturnAfterFirstMatch:(BOOL)shouldReturnAfterFirstMatch
{
    NSError *error = nil;
    FBClassChain * parsedChain = [FBClassChainQueryParser parseQuery:classChainPath error:&error];
    if (nil == parsedChain) {
        @throw [NSException exceptionWithName:@"FBClassChainQueryParseException" reason:error.localizedDescription userInfo:error.userInfo];
        return nil;
    }
    NSMutableArray<FBClassChainItem *> *lookupChain = parsedChain.elements.mutableCopy;
    FBClassChainItem *chainItem = lookupChain.firstObject;
    UIView *currentRoot = self;
    
    
    
    
    return nil;
}

- (NSArray<UIView *> *)fb_descendantsMatchingIdentifier:(NSString *)viewIdentifier
                            shouldReturnAfterFirstMatch:(BOOL)shouldReturnAfterFirstMatch
{
    // Not supported yet.
    return nil;
}

- (BOOL)matchClassChainItem:(FBClassChainItem *)classChainItem
{
    
}

#pragma mark - Element Query

- (NSString *)fb_generateElementQuery
{
    NSMutableString *elementQuery = [[NSMutableString alloc] init];
    [elementQuery appendString:NSStringFromClass(self.class)];
    if (self.fb_label.length > 0) {
        [elementQuery appendFormat:@"[label=%@]", self.fb_label];
    }
    [elementQuery appendFormat:@"[%@]", @(self.fb_position)];
    return elementQuery;
}

- (NSString *)fb_uuid
{
    return [NSString stringWithFormat:@"%p", self];
}

- (BOOL)fb_checkIfEnabled
{
    if ([self isKindOfClass:[UIControl class]]) {
        return [(UIControl *)self isEnabled];
    } else if ([self isKindOfClass:[UIControl class]]) {
        return [(UIBarItem *)self isEnabled];
    } else {
        return self.userInteractionEnabled;
    }
}

#pragma mark - NSPredict property list

- (CGFloat)fb_x
{
    return self.frame.origin.x;
}

- (CGFloat)fb_y
{
    return self.frame.origin.y;
}

- (CGFloat)fb_w
{
    return self.frame.size.width;
}

- (CGFloat)fb_h
{
    return self.frame.size.height;
}

- (NSInteger)fb_position
{
    return [self.superview.subviews indexOfObject:self];
}

- (NSString *)fb_label
{
    if ([self isKindOfClass:UILabel.class]) {
        return ((UILabel *)self).text;
    } else if ([self isKindOfClass:UIButton.class]) {
        return [((UIButton *)self) titleForState:UIControlStateNormal];
    } else if ([self isKindOfClass:UIBarItem.class]) {
        return [((UIBarItem *)self) title];
    } else {
        return @"";
    }
}

@end
