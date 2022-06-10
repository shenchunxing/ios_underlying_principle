//
//  ViewController.m
//  Interview02-super
//
//  Created by MJ Lee on 2018/5/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJPerson.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

/*
 1.print为什么能够调用成功？
 
 2.为什么self.name变成了ViewController等其他内容
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    struct abc = {
//        self,
//        [ViewController class]
//    };
//    objc_msgSendSuper2(abc, sel_registerName("viewDidLoad"));
    
//    NSObject *obj2 = [[NSObject alloc] init];
//
//    NSString *test = @"123";
    
    //cls是MJPerson类的地址
    //这里obj刚好指向的就是MJPerson类对象的前8个字节，也就是isa指针
    id cls = [MJPerson class];
    void *obj = &cls;
    [(__bridge id)obj print];
    
    //person内部有isa指针，指向MJPerson类对象的地址，还有一个name属性，内存偏移在isa后面的位置，isa是8个字节的指针。本质就是取出内存的前8个字节，就可以拿到MJPerson类对象地址
    MJPerson *person = [[MJPerson alloc] init];
    NSLog(@"%p %p",obj,object_getClass(person));
    [person print];
    
//    long long *p = (long long *)obj;
//    NSLog(@"%p %p", *(p+2), [ViewController class]);
    
//    struct MJPerson_IMPL
//    {
//        Class isa;
//        NSString *_name;
//    };
}


@end
