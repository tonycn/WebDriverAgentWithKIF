//
//  FBUIScrollCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-25.
//

#import "FBUIScrollCommand.h"

#import "UIView-KIFAdditions.h"


@implementation FBUIScrollCommand

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.action = [self.class actionString];
  }
  return self;
}

- (BOOL)executeOn:(UIView *)element
{
  NSAssert([element isKindOfClass:UIScrollView.class], @"Should be scroll view");
  if ([element isKindOfClass:UIScrollView.class]) {
    while (YES) {
      NSArray *elementsDidFind = [self.class findElementsByClassChain:self.until shouldReturnAfterFirstMatch:YES];
      if (elementsDidFind.count > 0) {
        return YES;
      }
      UIScrollView *scrollView = (id)element;
      CGPoint contentOffset = scrollView.contentOffset;
      contentOffset.x += self.x;
      contentOffset.y += self.y;
      [scrollView setContentOffset:contentOffset];
      if (contentOffset.x + scrollView.bounds.size.width > scrollView.contentSize.width
          && contentOffset.y + scrollView.bounds.size.height > scrollView.contentSize.height) {
        break;
      }
    }
  }
  return NO;
}

- (NSDictionary *)toDictionary
{
  NSMutableDictionary *dict = [[super toDictionary] mutableCopy];
  if (self.until) {
    dict[@"until"] = self.until;
  }
  if (self.x) {
    dict[@"x"] = @(self.x);
  }
  if (self.y) {
    dict[@"y"] = @(self.y);
  }
  return dict;
}


+ (NSString *)actionString
{
  return @"scroll";
}

@end
