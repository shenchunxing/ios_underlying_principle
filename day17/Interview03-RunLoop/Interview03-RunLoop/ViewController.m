//
//  ViewController.m
//  Interview03-RunLoop
//
//  Created by MJ Lee on 2018/5/31.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

NSMutableDictionary *runloops; //runloop保存在全局的字典里

void observeRunLoopActicities(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"kCFRunLoopEntry");
            break;
        case kCFRunLoopBeforeTimers:
            NSLog(@"kCFRunLoopBeforeTimers");
            break;
        case kCFRunLoopBeforeSources:
            NSLog(@"kCFRunLoopBeforeSources");
            break;
        case kCFRunLoopBeforeWaiting:
            NSLog(@"kCFRunLoopBeforeWaiting");
            break;
        case kCFRunLoopAfterWaiting: //唤醒
            NSLog(@"kCFRunLoopAfterWaiting");
            break;
        case kCFRunLoopExit:
            NSLog(@"kCFRunLoopExit");
            break;
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    NSRunLoop *runloop;
//    CFRunLoopRef runloop2;
//    runloops[thread] = runloop; //runloop里面是线程作为key，runloop作为value
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    CFRunLoopRef runloop2 = CFRunLoopGetCurrent();
    
    NSArray *array;
    CFArrayRef arry2;

    NSString *string;
    CFStringRef string2;

    //第一次获取runloop的时候，会自动创建
    //NSRunLoop是对CFRunLoopGetCurrent的包装，打印的地址NSRunLoop currentRunLoop]和CFRunLoopGetCurrent是不同的
    NSLog(@"%p %p", [NSRunLoop currentRunLoop], [NSRunLoop mainRunLoop]);
    NSLog(@"%p %p", CFRunLoopGetCurrent(), CFRunLoopGetMain());
    
    // 有序的
//    NSMutableArray *array;
//    [array addObject:@"123"];
//    array[0];
    
    // 无序的
//    NSMutableSet *set;
//    [set addObject:@"123"];
//    [set anyObject];
//
//    kCFRunLoopDefaultMode;
//    NSDefaultRunLoopMode;
    NSLog(@"%@", [NSRunLoop mainRunLoop]);
    
    
//    self.view.backgroundColor = [UIColor redColor];
    
    
    
    // kCFRunLoopCommonModes默认包括kCFRunLoopDefaultMode、UITrackingRunLoopMode
    
    
    // 创建Observer
//    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, observeRunLoopActicities, NULL);
//    // 添加Observer到RunLoop中
//    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
//    // 释放
//    CFRelease(observer);
    
    // 创建Observer
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault,
                                                                       kCFRunLoopAllActivities,
                                                                       YES,
                                                                       0,
                                                                       ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {
            case kCFRunLoopEntry: { //进入
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
                NSLog(@"kCFRunLoopEntry - %@", mode);
                CFRelease(mode);
                break;
            }
                
            case kCFRunLoopExit: { //退出
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
                NSLog(@"kCFRunLoopExit - %@", mode);
                CFRelease(mode);
                break;
            }
                
//            case kCFRunLoopBeforeTimers:
//                NSLog(@"kCFRunLoopBeforeTimers");
//                break;
//            case kCFRunLoopBeforeSources:
//                NSLog(@"kCFRunLoopBeforeSources");
//                break;
//            case kCFRunLoopBeforeWaiting:
//                NSLog(@"kCFRunLoopBeforeWaiting");
//                break;
//            case kCFRunLoopAfterWaiting: //唤醒
//                NSLog(@"kCFRunLoopAfterWaiting");
//                break;
            default:
                break;
        }
    });
    // 添加Observer到RunLoop中,kCFRunLoopCommonModes同时监听默认和滚动
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    // 释放
    CFRelease(observer);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //这里打断点bt，可以看到函数调用栈里面__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__，证明存在source0
//    NSLog(@"%s",__func__);
    
    //证明存在timers
    [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        NSLog(@"定时器-----------");
    }];
    
}

@end
