//
//  NSConditionDemo2.m
//  Interview04-线程同步
//
//  Created by 沈春兴 on 2022/6/14.
//  Copyright © 2022 MJ Lee. All rights reserved.
//

#import "NSConditionDemo2.h"

@interface NSConditionDemo2()
@property (strong, nonatomic) NSConditionLock *conditionLock;
@end

@implementation NSConditionDemo2

//按顺序执行线程的一种方案，可以设置线程
- (instancetype)init
{
    if (self = [super init]) {
        self.conditionLock = [[NSConditionLock alloc] initWithCondition:1];
    }
    return self;
}

- (void)otherTest
{
    [[[NSThread alloc] initWithTarget:self selector:@selector(__one) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(__two) object:nil] start];
    [[[NSThread alloc] initWithTarget:self selector:@selector(__three) object:nil] start];
}

- (void)__one
{
    [self.conditionLock lockWhenCondition:1];//加锁
    NSLog(@"__one");
    [self.conditionLock unlockWithCondition:2]; //解锁并设置状态为2
}

- (void)__two
{
    [self.conditionLock lockWhenCondition:2];
    NSLog(@"__two");
    [self.conditionLock unlockWithCondition:3];
    
}

- (void)__three
{
    [self.conditionLock lockWhenCondition:3];
    NSLog(@"__three");
    [self.conditionLock unlock];
    
}
@end
