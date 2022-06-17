//
//  OSSpinLockDemo.m
//  Interview04-线程同步
//
//  Created by MJ Lee on 2018/6/7.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "OSSpinLockDemo.h"
#import <libkern/OSAtomic.h>

@interface OSSpinLockDemo()
// High-level lock
@property (assign, nonatomic) OSSpinLock moneyLock;
@property (assign, nonatomic) OSSpinLock ticketLock;
@end

@implementation OSSpinLockDemo

/**
 通过llvm 指令si可以单步执行汇编，最后发现一直在循环执行某一段汇编指令，这就是典型的while循环。证明OSSpinLock是在自旋
 next: 一步执行汇编，遇到函数调用也会一步跨过
 */
- (instancetype)init
{
    if (self = [super init]) {
        self.moneyLock = OS_SPINLOCK_INIT;
        self.ticketLock = OS_SPINLOCK_INIT;
    }
    return self;
}

- (void)__drawMoney
{
    OSSpinLockLock(&_moneyLock);
    
    [super __drawMoney];
    
    OSSpinLockUnlock(&_moneyLock);
}

- (void)__saveMoney
{
    OSSpinLockLock(&_moneyLock);
    
    [super __saveMoney];
    
    OSSpinLockUnlock(&_moneyLock);
}

- (void)__saleTicket
{
    OSSpinLockLock(&_ticketLock);
    
    [super __saleTicket];
    
    OSSpinLockUnlock(&_ticketLock);
}

@end
