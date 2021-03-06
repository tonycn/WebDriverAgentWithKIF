//
//  UIView+FBHelper.m
//  WebDriverAgent
//
//  Created by jianjun on 2019-02-22.
//

#import "UIView+FBHelper.h"

#import "FBClassChainQueryParser.h"
#import "KIFTypist.h"
#import "NSString+FBVisualLength.h"

@implementation UIView (FBHelper)

+ (NSDictionary *)fb_dictionaryForView:(UIView *)view
{
  return [self fb_dictionaryForView:view classChain:nil];
}

+ (NSDictionary *)fb_dictionaryForView:(UIView *)view
                            classChain:(NSString *)chain
{
  NSString *chainWithSlash = chain ?: @"";
  if (chainWithSlash.length > 0 && ![chainWithSlash hasSuffix:@"/"]) {
    chainWithSlash = [chainWithSlash stringByAppendingString:@"/"];
  }
  NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
  info[@"type"] = NSStringFromClass(view.class);
  info[@"name"] = nil;
  info[@"value"] = nil;
  info[@"label"] = [view fb_label];
  info[@"classChain"] = [chainWithSlash stringByAppendingString:[view fb_generateElementQuery]];
  info[@"ELEMENT"] = [view fb_uuid];
  info[@"rect"] =  [self fb_formattedRectWithFrame:view.fb_wdFrame];
  info[@"frame"] = NSStringFromCGRect(CGRectIntegral(view.fb_wdFrame));
  info[@"isEnabled"] = [@([view fb_checkIfEnabled]) stringValue];
  info[@"isVisible"] = [@(![view isHidden]) stringValue];
  if ([view fb_isTextEditor]) {
    info[@"isInput"] = @(YES);
  }
  if ([view isKindOfClass:[UIScrollView class]]) {
    info[@"isScrollable"] = @(YES);
  }
  
  NSArray <UIView *> *childElements = view.subviews;
  if ([childElements count]) {
    info[@"children"] = [[NSMutableArray alloc] init];
    for (UIView *childView in childElements) {
      [info[@"children"] addObject:[self fb_dictionaryForView:childView classChain:info[@"classChain"]]];
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

#pragma mark -

- (NSArray<UIView *> *)fb_descendantsMatchingProperty:(NSString *)property
                                                value:(NSString *)value
                                        partialSearch:(BOOL)partialSearch
{
  return nil;
}

#pragma mark -
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
  return [self fb_descendantsMatchingClassChain:lookupChain
                                     chainIndex:0
                    shouldReturnAfterFirstMatch:shouldReturnAfterFirstMatch];
}

- (NSArray<UIView *> *)fb_descendantsMatchingClassChain:(NSArray<FBClassChainItem *> *)lookupChain
                                             chainIndex:(NSUInteger)chainIndex
                            shouldReturnAfterFirstMatch:(BOOL)shouldReturnAfterFirstMatch
{
  if (lookupChain.count <= chainIndex) {
    return nil;
  }
  FBClassChainItem *chainItem = [lookupChain objectAtIndex:chainIndex];
  UIView *currentRoot = self;
  BOOL matched = [currentRoot fb_matchClassChainItem:chainItem];
  if (chainIndex + 1 == lookupChain.count) {
    if (matched) {
      return @[currentRoot];
    } else if (!chainItem.isDescendant) {
      return nil;
    }
  }
  NSMutableArray *elementsFound = [NSMutableArray array];
  for (UIView *subView in currentRoot.subviews) {
    if (matched) {
      NSArray *elements = [subView fb_descendantsMatchingClassChain:lookupChain
                                                         chainIndex:chainIndex+1
                                        shouldReturnAfterFirstMatch:shouldReturnAfterFirstMatch];
      if (elements.count > 0 && shouldReturnAfterFirstMatch) {
        return elements;
      } else if (elements.count > 0) {
        [elementsFound addObjectsFromArray:elements];
      }
    }
    
    if (chainItem.isDescendant) {
      NSArray *elements = [subView fb_descendantsMatchingClassChain:lookupChain
                                                         chainIndex:chainIndex
                                        shouldReturnAfterFirstMatch:shouldReturnAfterFirstMatch];
      if (elements.count > 0 && shouldReturnAfterFirstMatch) {
        return elements;
      } else if (elements.count > 0) {
        [elementsFound addObjectsFromArray:elements];
      }
    }
  }
  
  return elementsFound;
}

#pragma mark -
- (NSArray<UIView *> *)fb_descendantsMatchingIdentifier:(NSString *)viewIdentifier
                            shouldReturnAfterFirstMatch:(BOOL)shouldReturnAfterFirstMatch
{
  // Not supported yet.
  return nil;
}

- (BOOL)fb_matchClassChainItem:(FBClassChainItem *)classChainItem
{
  if (![classChainItem.type isEqualToString:self.fb_type]) {
    return NO;
  }
  
  if (!(classChainItem.position == 0
        || classChainItem.position == self.fb_position
        || classChainItem.position == self.fb_minusPosition)) {
    return NO;
  }
  
  if (classChainItem.predicates) {
    for (FBSelfPredicateItem *predicate in classChainItem.predicates) {
      if (![predicate.value evaluateWithObject:self]) {
        return NO;
      }
    }
  }
  
  if (self.hidden) {
    return NO;
  }
  
  return YES;
}

#pragma mark - Element Query

- (NSString *)fb_generateElementQuery
{
  return [self fb_generateElementQueryWithPosition:YES];
}

- (NSString *)fb_generateElementQueryWithPosition:(BOOL)withPosition
{
  NSMutableString *elementQuery = [[NSMutableString alloc] init];
  [elementQuery appendString:NSStringFromClass(self.class)];
  if (self.fb_label.length > 0) {
    [elementQuery appendFormat:@"[`fb_label == '%@'`]", self.fb_label];
  }
  if (self.fb_index > 0) {
    [elementQuery appendFormat:@"[`fb_index == %d`]", self.fb_index];
  }

  NSInteger pos = self.fb_position;
  if (withPosition && pos > 0) {
    [elementQuery appendFormat:@"[%@]", @(pos)];
  }
  return elementQuery;
}

- (NSString *)fb_generateElementClassChain
{
  NSMutableString *classChain = [[self fb_generateElementQuery] mutableCopy];
  UIView *superView = self.superview;
  while (superView) {
    [classChain insertString:@"/" atIndex:0];
    [classChain insertString:[superView fb_generateElementQuery] atIndex:0];
    superView = superView.superview;
  }
  return classChain;
}

- (NSString *)fb_generateElementReducedClassChainByMaxLevel:(NSInteger)level
{
  NSMutableString *classChain = [[self fb_generateElementQueryWithPosition:NO] mutableCopy];
  UIView *superView = self.superview;
  NSInteger descendantLevel = 1;
  while (superView) {
    [classChain insertString:@"/" atIndex:0];
    [classChain insertString:[superView fb_generateElementQueryWithPosition:NO] atIndex:0];
    superView = superView.superview;
    ++descendantLevel;
    if (superView != nil && descendantLevel == level) {
      [classChain insertString:@"**/" atIndex:0];
      break;
    }
  }
  return classChain;
}


- (NSString *)fb_uuid
{
  return [NSString stringWithFormat:@"%p", self];
}

- (NSString *)fb_type
{
  return NSStringFromClass(self.class);
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

- (NSInteger)fb_position
{
  if ([self isKindOfClass:[UITableViewCell class]]) {
    return 0;
  }
  if ([self isKindOfClass:[UICollectionViewCell class]]) {
    return 0;
  }
  return [self.superview.subviews indexOfObject:self] + 1;
}

- (NSInteger)fb_index
{
  if ([self isKindOfClass:[UITableViewCell class]]) {
    UITableViewCell *cell = (id)self;
    UITableView *tableView = [self fb_findSuperViewOfClass:UITableView.class];
    if (tableView) {
      NSIndexPath *indexPath = [tableView indexPathForCell:cell];
      return 10000 * indexPath.section + indexPath.row + 1;
    }
  }
  if ([self isKindOfClass:[UICollectionViewCell class]]) {
    UICollectionViewCell *cell = (id)self;
    UICollectionView *collectionView = [self fb_findSuperViewOfClass:UICollectionView.class];
    if (collectionView) {
      NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
      return 10000 * indexPath.section + indexPath.row + 1;
    }
  }
  return 0;
}

- (NSInteger)fb_minusPosition
{
  return self.superview.subviews.count - self.fb_position - 1;
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

- (NSString *)fb_inputTextValue
{
  if ([self isKindOfClass:UITextField.class]) {
    return ((UITextField *)self).text;
  } else if ([self isKindOfClass:UITextView.class]) {
    return [((UITextView *)self) text];
  } else {
    return nil;
  }
}

- (CGRect)fb_wdFrame
{
  CGRect windowFrame = [self.window convertRect:self.bounds fromView:self];
  return windowFrame;
}

- (NSDictionary *)fb_wdRect
{
  CGRect frame = self.fb_wdFrame;
  return @{
           @"x": @(CGRectGetMinX(frame)),
           @"y": @(CGRectGetMinY(frame)),
           @"width": @(CGRectGetWidth(frame)),
           @"height": @(CGRectGetHeight(frame)),
           };
}

- (BOOL)fb_clearTextWithError:(NSError **)error
{
  NSUInteger preClearTextLength = 0;
  
  while ([self.fb_inputTextValue fb_visualLength] != preClearTextLength) {
    [KIFTypist enterCharacter:@"\b"];
  }
  return YES;
}

- (UIView *)fb_findSuperViewOfClass:(Class)viewClass
{
  UIView *superView = self.superview;
  while (superView) {
    if ([superView isKindOfClass:viewClass]) {
      return superView;
    }
    superView = superView.superview;
  }
  return nil;
}

@end

@implementation UIView (FBEditorHelper)

- (BOOL)fb_isTextEditor
{
  return [self isKindOfClass:UITextView.class]
  || [self isKindOfClass:UITextField.class];
}

@end
