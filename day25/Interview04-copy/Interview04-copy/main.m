//
//  main.m
//  Interview04-copy
//
//  Created by MJ Lee on 2018/6/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

// 拷贝的目的：产生一个副本对象，跟源对象互不影响
// 修改了源对象，不会影响副本对象
// 修改了副本对象，不会影响源对象

/*
 iOS提供了2个拷贝方法
 1.copy，不可变拷贝，产生不可变副本
 
 2.mutableCopy，可变拷贝，产生可变副本
 
 深拷贝和浅拷贝
 1.深拷贝：内容拷贝，产生新的对象
 2.浅拷贝：指针拷贝，没有产生新的对象
 */

void test()
{
    //        NSString *str1 = [NSString stringWithFormat:@"test"];
    //        NSString *str2 = [str1 copy]; // 返回的是NSString
    //        NSMutableString *str3 = [str1 mutableCopy]; // 返回的是NSMutableString
    
    NSMutableString *str1 = [NSMutableString stringWithFormat:@"test"];
    NSString *str2 = [str1 copy];//深拷贝
    NSMutableString *str3 = [str1 mutableCopy];//深拷贝
    
    NSLog(@"%@ %@ %@", str1, str2, str3);
    NSLog(@"%p %p %p", str1, str2, str3);
}

void test2()
{
    NSString *str1 = [[NSString alloc] initWithFormat:@"test9889989898989889"];
    //对于不可变字符串，copy此时相当于retain，引用计数会+1
    NSString *str2 = [str1 copy]; // 浅拷贝，指针拷贝，没有产生新对象
    NSMutableString *str3 = [str1 mutableCopy]; // 深拷贝，内容拷贝，有产生新对象
    
    NSLog(@"%lu",(unsigned long)str1.retainCount);// 2
    NSLog(@"%@ %@ %@", str1, str2, str3);
    NSLog(@"%p %p %p", str1, str2, str3);
    
    [str3 release];
    [str2 release];
    [str1 release];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSMutableString *str1 = [[NSMutableString alloc] initWithFormat:@"test"];
        NSString *str2 = [str1 copy]; // 深拷贝
        NSMutableString *str3 = [str1 mutableCopy]; // 深拷贝
        
//        [str1 appendString:@"111"];
//        [str3 appendString:@"333"];
//
//        NSLog(@"%@ %@ %@", str1, str2, str3);
        
        [str1 release];
        [str2 release];
        [str3 release];
        
        test2();
    }
    return 0;
}
