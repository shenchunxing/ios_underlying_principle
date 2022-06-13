//
//  ViewController.m
//  Interview03-线程保活
//
//  Created by MJ Lee on 2018/6/3.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJThread.h"

@interface ViewController ()
@property (strong, nonatomic) MJThread *thread;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.thread = [[MJThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [self.thread start];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO]; //waitUntilDone是否等子线程任务完成才执行，no:不卡住，立即执行
    NSLog(@"123");
}

// 子线程需要执行的任务
- (void)test
{
    NSLog(@"%s %@", __func__, [NSThread currentThread]);
}

// 这个方法的目的：线程保活
- (void)run {
    NSLog(@"%s %@", __func__, [NSThread currentThread]);
    
    // 往RunLoop里面添加Source\Timer\Observer，如果没有Source\Timer\Observer，runloop会退出
    [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
    
    NSLog(@"%s ----end----", __func__);
}

@end
