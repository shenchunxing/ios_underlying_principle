//
//  MutexDemo.m
//  Interview04-线程同步
//
//  Created by MJ Lee on 2018/6/11.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MutexDemo.h"
#import <pthread.h>

@interface MutexDemo()
@property (assign, nonatomic) pthread_mutex_t ticketMutex;
@property (assign, nonatomic) pthread_mutex_t moneyMutex;
@end

@implementation MutexDemo

- (void)__initMutex:(pthread_mutex_t *)mutex
{
    // 静态初始化
    //        pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    
//    // 初始化属性
//    pthread_mutexattr_t attr;
//    pthread_mutexattr_init(&attr);
//    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_DEFAULT);
//    // 初始化锁
//    pthread_mutex_init(mutex, &attr);
//    // 销毁属性
//    pthread_mutexattr_destroy(&attr);
    
    // 初始化属性
//    pthread_mutexattr_t attr;
//    pthread_mutexattr_init(&attr);
//    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_DEFAULT);
    // 初始化锁
    pthread_mutex_init(mutex, NULL);//传空就是PTHREAD_MUTEX_DEFAULT
    // 销毁属性
//    pthread_mutexattr_destroy(&attr);
}

- (instancetype)init
{
    if (self = [super init]) {
        [self __initMutex:&_ticketMutex];
        [self __initMutex:&_moneyMutex];
    }
    return self;
}

// 死锁：永远拿不到锁
/**
 通过llvm c可以继续下一个断点，指令si可以单步执行汇编，最后发现最后执行到syscall（非常内核的函数）后，断点消失了，去休眠去了
 */
- (void)__saleTicket
{
    pthread_mutex_lock(&_ticketMutex);
    
    [super __saleTicket];
    
    pthread_mutex_unlock(&_ticketMutex);
}

- (void)__saveMoney
{
    pthread_mutex_lock(&_moneyMutex);
    
    [super __saveMoney];
    
    pthread_mutex_unlock(&_moneyMutex);
}

- (void)__drawMoney
{
    pthread_mutex_lock(&_moneyMutex);
    
    [super __drawMoney];
    
    pthread_mutex_unlock(&_moneyMutex);
}

- (void)dealloc
{
    pthread_mutex_destroy(&_moneyMutex);
    pthread_mutex_destroy(&_ticketMutex);
}

@end
