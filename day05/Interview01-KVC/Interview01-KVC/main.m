//
//  main.m
//  Interview01-KVC
//
//  Created by MJ Lee on 2018/5/3.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"
#import "MJObserver.h"
//MARK:kvc过程？
/**
 1.当一个对象调用setValue方法时，方法内部会做以下操作：
 1). 检查是否存在相应的key的set方法，如果存在，就调用set方法。
 2). 如果set方法不存在，就会查找与key相同名称并且带下划线的成员变量，如果有，则直接给成员变量属性赋值。
 3). 如果没有找到_key，就会查找相同名称的属性key，如果有就直接赋值。
 4). 如果还没有找到，则调用valueForUndefinedKey:和setValue:forUndefinedKey:方法。
 这些方法的默认实现都是抛出异常，我们可以根据需要重写它们。
 */

//MARK:setValueForKey 和 setObjectForKey有什么区别？
/**
 setValue的key只能是字符串。value可以为空，系统会自动调用remove方法，移除
 setObject的key可以为任何类型，value不能为空，会崩溃。

 valueforkey:key如果不匹配，会进入valueForundefinedKey方法，默认crash。
 objectforkey：默认和valueforkey一样，但是当key里面包含@, objectforkey会自动过滤@，不会carsh，valueforkey会直接崩溃。
 */

//MARK:KVC优缺点？
/**
 优点：没有property的变量（私有）也能通过KVC进行设置，或者简化代码（多级属性）
 缺点：如果key只写错，编写的时候不会报错，但是运行的时候会报错
 */
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJObserver *observer = [[MJObserver alloc] init];
        MJPerson *person = [[MJPerson alloc] init];
        
        // 添加KVO监听
        [person addObserver:observer forKeyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        
        // 通过KVC修改age属性
        [person setValue:@10 forKey:@"age"];
        
        // setAge:
        
        // 移除KVO监听
        [person removeObserver:observer forKeyPath:@"age"];
        
        
        person.age = 10;
        
        NSLog(@"%@", [person valueForKey:@"age"]);
        NSLog(@"%@", [person valueForKeyPath:@"cat.weight"]);
        
        
        NSLog(@"%d", person.age);
        
        [person setValue:[NSNumber numberWithInt:10] forKey:@"age"];
        [person setValue:@10 forKey:@"age"];
        person.cat = [[MJCat alloc] init];
        [person setValue:@10 forKeyPath:@"cat.weight"];
        
        NSLog(@"%d", person.age);
        
    
    }
    return 0;
}
