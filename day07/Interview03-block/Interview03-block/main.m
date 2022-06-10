//
//  main.m
//  Interview03-block
//
//  Created by MJ Lee on 2018/5/9.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

struct __main_block_desc_0 {
    size_t reserved; //保留，暂时不会用
    size_t Block_size;//大小
};

struct __block_impl {
    void *isa;//isa指针
    int Flags;
    int Reserved;
    void *FuncPtr;//函数地址，block执行的时候会调用
};

struct __main_block_impl_0 {
    struct __block_impl impl;//block实现
    struct __main_block_desc_0* Desc;//描述
    int age;
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        ^{
            NSLog(@"this is a block!");
            NSLog(@"this is a block!");
            NSLog(@"this is a block!");
            NSLog(@"this is a block!");
        }();
        
        int age = 20;
        
        void (^block)(int, int) =  ^(int a , int b){
            NSLog(@"this is a block! -- %d", age);
            NSLog(@"this is a block!");
            NSLog(@"this is a block!");
            NSLog(@"this is a block!");
        };
        
        
        
        struct __main_block_impl_0 *blockStruct = (__bridge struct __main_block_impl_0 *)block;
        
        
        
        block(10, 10);
    }
    return 0;
}
