/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIButton *button;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  
  self.label = [[UILabel alloc] init];
  self.label.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview:self.label];
  
  
  self.button = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  [self.button addTarget:self action:@selector(buttonDidTap:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.button];

}

- (IBAction)deadlockApp:(id)sender
{
  dispatch_sync(dispatch_get_main_queue(), ^{
    // This will never execute
  });
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  
  self.label.frame = CGRectMake(0, 0, 240, 80);
  self.label.center = self.view.center;
  [self updateText];
  
  self.button.frame = CGRectMake(0, 0, 240, 80);
  self.button.center = CGPointMake(self.view.center.x, self.view.center.y + 100);
}

- (void)updateText
{
  self.label.text = [NSString stringWithFormat:@"Push %@", @(self.navigationController.childViewControllers.count)];
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelDidTap:)];
  [self.label addGestureRecognizer:tapGesture];
  self.label.userInteractionEnabled = YES;
  
  [self.button setTitle:[NSString stringWithFormat:@"Pop %@", @(self.navigationController.childViewControllers.count)] forState:UIControlStateNormal];
}

- (void)labelDidTap:(UITapGestureRecognizer *)tapGesture
{
//  static NSInteger count = 1;
//  self.label.text = [@"tap" stringByAppendingString:[@(count) stringValue]];
//  ++count;
  
  ViewController *vc = [[ViewController alloc] init];
  vc.title = [NSString stringWithFormat:@"demo %@", @(self.navigationController.childViewControllers.count)];
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)buttonDidTap:(UIButton *)btn
{
//  static NSInteger count = 1;
//  [self.button setTitle:[@"tap" stringByAppendingString:[@(count) stringValue]]
//               forState:UIControlStateNormal];
//  ++count;
  
  if (self.navigationController.childViewControllers.count > 1) {
    [self.navigationController popViewControllerAnimated:YES];
  }
}

@end
