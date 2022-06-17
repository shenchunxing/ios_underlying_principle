//
//  main.m
//  Interview16-autorelease
//
//  Created by MJ Lee on 2018/7/2.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"

extern void _objc_autoreleasePoolPrint(void);

int main(int argc, const char * argv[]) {
    //每一个@autoreleasepool会生成一个POOL_BOUNDARY，标记autoreleasepool开始的位置（除去autoreleasepool内部自身的成员后，下一个地址就是POOL_BOUNDARY，也就是开始存储其他autorelease对象的地址）
    //objc[61589]: [0x10680c038]  ################  POOL 0x10680c038，这个0x10680c038就是POOL_BOUNDARY地址，是这一页page的对象填充开始位置
    //objc[61589]: [0x10680c000]  ................  PAGE (full)  (cold) ，page已经满了full，cold表示不是当前page
    @autoreleasepool { //  r1 = push() //
        
        MJPerson *p1 = [[[MJPerson alloc] init] autorelease];
        MJPerson *p2 = [[[MJPerson alloc] init] autorelease];
        
        @autoreleasepool { // r2 = push()
            for (int i = 0; i < 600; i++) { //600 * 8 = 4800 超过了4096 - 56（autoreleasepool对象内部成员 7 * 8 = 56） = 4040个字节，因此会分页
                MJPerson *p3 = [[[MJPerson alloc] init] autorelease];
            }
            
            //objc[61589]: [0x106010000]  ................  PAGE  (hot)，hot表示目前是在当前page下
            //objc[61589]: [0x106010350]  ################  POOL 0x106010350 这一页page的对象填充结束位置
            //释放的时候，按照栈的数据结构，FILO的形式释放
            @autoreleasepool { // r3 = push()
                MJPerson *p4 = [[[MJPerson alloc] init] autorelease];
                
                _objc_autoreleasePoolPrint();
            } // pop(r3)
            
        } // pop(r2)
        
        
    } // pop(r1)
    
    
    return 0;
}

void test()
{
    //        atautoreleasepoolobj = objc_autoreleasePoolPush();
    // atautoreleasepoolobj = 0x1038
    
    for (int i = 0; i < 1000; i++) {
        MJPerson *person = [[[MJPerson alloc] init] autorelease];
    } // 8000个字节
    
    //        objc_autoreleasePoolPop(0x1038);
}


#pragma mark - autoreleasepool底层结构
//转成c++。可以看到内部有__AtAutoreleasePoolg这个数据结构
//__AtAutoreleasePoolg里面有objc_autoreleasePoolPush、objc_autoreleasePoolPop方法
/*
 
 struct __AtAutoreleasePool {
    __AtAutoreleasePool() { // 构造函数，在创建结构体的时候调用
        atautoreleasepoolobj = objc_autoreleasePoolPush();
    }
 
    ~__AtAutoreleasePool() { // 析构函数，在结构体销毁的时候调用
        objc_autoreleasePoolPop(atautoreleasepoolobj);
    }
 
    void * atautoreleasepoolobj;
 };
 
 {
    __AtAutoreleasePool __autoreleasepool;
    MJPerson *person = ((MJPerson *(*)(id, SEL))(void *)objc_msgSend)((id)((MJPerson *(*)(id, SEL))(void *)objc_msgSend)((id)((MJPerson *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("MJPerson"), sel_registerName("alloc")), sel_registerName("init")), sel_registerName("autorelease"));
 }
 
 
    atautoreleasepoolobj = objc_autoreleasePoolPush();
 
    MJPerson *person = [[[MJPerson alloc] init] autorelease];
 
    objc_autoreleasePoolPop(atautoreleasepoolobj);
 */
