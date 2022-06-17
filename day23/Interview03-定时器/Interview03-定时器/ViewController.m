//
//  ViewController.m
//  Interview03-定时器
//
//  Created by MJ Lee on 2018/6/19.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJProxy.h"

@interface ViewController ()
@property (strong, nonatomic) CADisplayLink *link;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 保证调用频率和屏幕的刷帧频率一致，60FPS,1秒钟调用60次
    //      self
    //timer      MJProxy
    //MJProxy对self是弱引用，可以解除循环引用
    self.link = [CADisplayLink displayLinkWithTarget:[MJProxy proxyWithTarget:self] selector:@selector(linkTest)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[MJProxy proxyWithTarget:self] selector:@selector(timerTest) userInfo:nil repeats:YES];
    
    //无法解决循环引用，target内部会赋值给里面的强引用属性，还是强引用
//    __weak typeof(self) weakSelf = self;
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:weakSelf selector:@selector(timerTest) userInfo:nil repeats:YES];
    
    //一种可以解决的方案
//    __weak typeof(self) weakSelf = self;
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        [weakSelf timerTest];
//    }];
}

- (void)timerTest
{
    NSLog(@"%s", __func__);
}

- (void)linkTest
{
    NSLog(@"%s", __func__);
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [self.link invalidate];
//    [self.timer invalidate];
}

@end
