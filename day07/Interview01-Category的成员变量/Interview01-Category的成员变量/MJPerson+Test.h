//
//  MJPerson+Test.h
//  Interview01-Category的成员变量
//
//  Created by MJ Lee on 2018/5/9.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

@interface MJPerson (Test)
//{
//    int _weight; //分类不能添加成员变量
//}

@property (assign, nonatomic) int weight;


@property (copy, nonatomic) NSString* name;

//- (void)setWeight:(int)weight;
//- (int)weight;

@end
