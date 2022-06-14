//
//  main.m
//  Interview03-定时器
//
//  Created by MJ Lee on 2018/6/19.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MJProxy.h"
#import "MJProxy1.h"
#import "ViewController.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        ViewController *vc = [[ViewController alloc] init];
        
        MJProxy *proxy1 = [MJProxy proxyWithTarget:vc];
        
        MJProxy1 *proxy2 = [MJProxy1 proxyWithTarget:vc];
        
        //isKindOfClass也被消息转发了，变成了[vc isKindOfClass:[ViewController class]],
        //因此返回true
        NSLog(@"%d %d",
              [proxy1 isKindOfClass:[ViewController class]],
              
              [proxy2 isKindOfClass:[ViewController class]]);
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
