//
//  MJPerson+Test.m
//  Interview01-Category的成员变量
//
//  Created by MJ Lee on 2018/5/9.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson+Test.h"

#define MJKey [NSString stringWithFormat:@"%p", self]

@implementation MJPerson (Test)
/**
 存在的问题:
 1线程不安全，
 2.每次新增一个属性都需要创建全局字典，重写setter getter
 3.字典内存会一直存在
 */
NSMutableDictionary *names_;
NSMutableDictionary *weights_;
+ (void)load
{
    weights_ = [NSMutableDictionary dictionary];
    names_ = [NSMutableDictionary dictionary];
}

- (void)setName:(NSString *)name
{
//    NSString *key = [NSString stringWithFormat:@"%p", self];
    names_[MJKey] = name;
}

- (NSString *)name
{
//    NSString *key = [NSString stringWithFormat:@"%p", self];
    return names_[MJKey];
}

- (void)setWeight:(int)weight
{
//    NSString *key = [NSString stringWithFormat:@"%p", self];
    weights_[MJKey] = @(weight);
}

- (int)weight
{
//    NSString *key = [NSString stringWithFormat:@"%p", self];
    return [weights_[MJKey] intValue];
}

//int weight_;
//
//- (void)setWeight:(int)weight
//{
//    weight_ = weight;
//}
//
//- (int)weight
//{
//    return weight_;
//}

//- (void)setWeight:(int)weight
//{
//    _weight = weight;
//}
//
//- (int)weight
//{
//    return _weight;
//}

@end
