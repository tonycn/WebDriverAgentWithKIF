//
//  FBUIScrollCommand.m
//  WebDriverAgentWithKIF
//
//  Created by jianjun on 2019-03-25.
//

#import "FBUIScrollCommand.h"

#import "UIView-KIFAdditions.h"


@implementation FBUIScrollCommand

- (instancetype)initWithAttributes:(NSDictionary *)attrs {
  self = [super initWithAttributes:attrs];
  if (self) {
    self.x = [attrs[@"x"] floatValue];
    self.y = [attrs[@"y"] floatValue];
    self.until = attrs[@"until"];
  }
  return self;
}

- (void)executeOn:(UIView * _Nullable)element
      finishBlock:(void (^)(BOOL))finishBlock
{
  NSAssert([element isKindOfClass:UIScrollView.class], @"Should be scroll view");
  if ([element isKindOfClass:UIScrollView.class]) {
    if (self.until.length > 0) {
      [self.class scroll:(id)element
                byOffset:CGPointMake(self.x, self.y)
                 fromTop:YES
                   until:self.until
                 didFind:^(UIView * _Nullable element) {
        finishBlock(element != nil);
      }];
    } else {
      UIScrollView *scrollView = (id)element;
      CGPoint contentOffset = scrollView.contentOffset;
      contentOffset.x += self.x;
      contentOffset.y += self.y;
      [scrollView setContentOffset:contentOffset];
      finishBlock(YES);
      return;
    }
  } else {
    finishBlock(NO);
  }
}

+ (void)scroll:(UIScrollView *)scrollView
      byOffset:(CGPoint)offset
       fromTop:(BOOL)fromTop
         until:(NSString *)until
       didFind:(void (^)(UIView * _Nullable))didFindBlock
{
  if (fromTop) {
    scrollView.contentOffset = CGPointZero;
  }
  CGPoint contentOffset = scrollView.contentOffset;
  contentOffset.x += offset.x;
  contentOffset.y += offset.y;
  [scrollView setContentOffset:contentOffset];
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    NSArray *elements = [self findElementsByClassChain:until shouldReturnAfterFirstMatch:YES];
    if (elements.count > 0) {
      didFindBlock(elements.firstObject);
      return;
    } else {
      if (contentOffset.x + scrollView.bounds.size.width >= scrollView.contentSize.width
          && contentOffset.y + scrollView.bounds.size.height >= scrollView.contentSize.height) {
        didFindBlock(nil);
      } else {
        [self scroll:scrollView byOffset:offset fromTop:NO until:until didFind:didFindBlock];
      }
    }
  });
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
