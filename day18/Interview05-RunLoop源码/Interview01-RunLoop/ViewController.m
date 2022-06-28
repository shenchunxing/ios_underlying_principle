//
//  ViewController.m
//  Interview01-RunLoop
//
//  Created by MJ Lee on 2018/3/26.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%p", [NSRunLoop currentRunLoop]);
    NSLog(@"%p", [NSRunLoop mainRunLoop]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"点击了屏幕");
}


@end
