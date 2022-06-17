//
//  ViewController.m
//  Interview16-weak
//
//  Created by MJ Lee on 2018/7/1.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJPerson.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ARC是LLVM编译器和Runtime系统相互协作的一个结果
    
    __strong MJPerson *person1;
    __weak MJPerson *person2;
    __unsafe_unretained MJPerson *person3;
    
    
    NSLog(@"111");
    
    {
        MJPerson *person = [[MJPerson alloc] init];
        
        person3 = person;
        int a;
        //(__bridge void *)person是取出person存储的地址，也就是MJPerson对象的地址
        //&person,打印的是指针在栈上的地址
        NSLog(@"%p %p  %p  %p",person,(__bridge void *)person , &person, &a);
    }
    
    NSLog(@"222 - %@", person3);
}


@end
