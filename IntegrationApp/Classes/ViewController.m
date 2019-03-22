/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITextField *text;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIButton *button;

@property (strong, nonatomic) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  
  self.text = [[UITextField alloc] init];
  self.text.borderStyle = UITextBorderStyleLine;
  [self.view addSubview:self.text];
  
  self.label = [[UILabel alloc] init];
  self.label.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview:self.label];
  
  self.button = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
  [self.button addTarget:self action:@selector(buttonDidTap:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.button];
  
  self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  [self.view addSubview:self.tableView];
  
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
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
  
  CGRect frame = CGRectMake(0, 0, 240, 40);
  frame.origin = CGPointMake(40, 120);
  self.text.frame = frame;

  frame.origin = CGPointMake(40, 160);
  self.label.frame = frame;
  
  frame.origin = CGPointMake(40, 200);
  self.button.frame = frame;
  
  [self updateText];
  
  CGRect rect = CGRectMake(0, 320, self.view.frame.size.width, self.view.frame.size.height - 320);
  self.tableView.frame = rect;
  self.tableView.backgroundView.backgroundColor = [UIColor lightGrayColor];
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

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [[UITableViewCell alloc] init];
  cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", indexPath.row];
  return cell;
}

@end
