//
//  ViewController.m
//  STTextView
//
//  Created by StriEver on 17/5/22.
//  Copyright © 2017年 StriEver. All rights reserved.
//

#import "ViewController.h"
#import "STTextView.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet STTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    STTextView * tv = [[STTextView alloc]initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 20)];
    tv.layer.borderColor = [UIColor lightGrayColor].CGColor;
    tv.layer.borderWidth = 1;
    [self.view addSubview:tv];
    tv.placeholder = @"我是占位符";
    tv.placeholderColor = [UIColor lightGrayColor];
    tv.verticalSpacing = 10;
    tv.textContainerInset = UIEdgeInsetsMake(15, 10, 15, 10);
    tv.textViewAutoHeight = ^(CGFloat height){
    };
    tv.maxHeight = 200;
    tv.minHeight = 35;
    tv.backgroundColor = [UIColor whiteColor];
    tv.text = @"";

    
//    STTextView * tv1 = [[STTextView alloc]initWithFrame:CGRectMake(10, 210, self.view.frame.size.width - 20, 20)];
//    tv1.backgroundColor = [UIColor greenColor];
//    [self.view addSubview:tv1];
//    tv1.isAutoHeight = NO;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
