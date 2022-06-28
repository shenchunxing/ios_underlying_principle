//
//  ViewController.m
//  Interview01
//
//  Created by MJ Lee on 2018/4/23.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJPerson.h"
#import <objc/runtime.h>

@interface ViewController ()
@property (strong, nonatomic) MJPerson *person1;
@property (strong, nonatomic) MJPerson *person2;
@end

//@implementation NSObject
//
//- (Class)class
//{
//    return object_getClass(self);
//}
//
//@end

// 反编译工具 - Hopper

@implementation ViewController

// MARK: - KVO的优缺点
/**
 优点

 1、可以方便快捷的实现两个对象的关联同步，例如view & model
 2、能够观察到新值和旧值的变化
 3、可以方便的观察到嵌套类型的数据变化


 缺点

 1、观察对象通过string类型设置，如果写错或者变量名改变，编译时可以通过但是运行时会发生crash
 2、观察多个值需要在代理方法中多个if判断
 3、忘记移除观察者或重复移除观察者会导致crash
 */

// MARK: - 给KVO添加筛选条件
/**
 重写automaticallyNotifiesObserversForKey，需要筛选的key返回NO。
 setter里添加判断后手动触发KVO

 + (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
     if ([key isEqualToString:@"age"]) {
         return NO;
     }
     return [super automaticallyNotifiesObserversForKey:key];
 }
 ​
 - (void)setAge:(NSInteger)age {
     if (age >= 18) {
         [self willChangeValueForKey:@"age"];
         _age = age;
         [self didChangeValueForKey:@"age"];
     }else {
         _age = age;
     }
 }
 */

// MARK: - 使用KVC修改会触发KVO吗？
/**
 会，只要accessInstanceVariablesDirectly返回YES，通过KVC修改成员变量的值会触发KVO。
 这说明KVC内部调用了willChangeValueForKey:方法和didChangeValueForKey:方法
 */

// MARK: - KVO的崩溃与防护
/**
 崩溃原因：

 KVO 添加次数和移除次数不匹配，大部分是移除多于注册。
 被观察者dealloc时仍然注册着 KVO，导致崩溃。
 添加了观察者，但未实现 observeValueForKeyPath:ofObject:change:context: 。
 
 防护方案1：
 直接使用facebook开源框架KVOController
 防护方案2：
 自定义一个哈希表，记录观察者和观察对象的关系。
 使用fishhook替换 addObserver:forKeyPath:options:context:，在添加前先判断是否已经存在相同观察者，不存在才添加，避免重复触发造成bug。
 使用fishhook替换removeObserver:forKeyPath:和removeObserver:forKeyPath:context，移除之前判断是否存在对应关系，如果存在才释放。
 使用fishhook替换dealloc，执行dealloc前判断是否存在未移除的观察者，存在的话先移除。
 */

- (void)printMethodNamesOfClass:(Class)cls
{
    unsigned int count;
    // 获得方法数组
    Method *methodList = class_copyMethodList(cls, &count);
    
    // 存储方法名
    NSMutableString *methodNames = [NSMutableString string];
    
    // 遍历所有的方法
    for (int i = 0; i < count; i++) {
        // 获得方法
        Method method = methodList[i];
        // 获得方法名
        NSString *methodName = NSStringFromSelector(method_getName(method));
        // 拼接方法名
        [methodNames appendString:methodName];
        [methodNames appendString:@", "];
    }
    
    // 释放
    free(methodList);
    
    // 打印方法名
    NSLog(@"%@ %@", cls, methodNames);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.person1 = [[MJPerson alloc] init];
    self.person1.age = 1;
    
    self.person2 = [[MJPerson alloc] init];
    self.person2.age = 2;
    
    // 给person1对象添加KVO监听，此时person1的类对象已经变成了NSKVONotifying_MJPerson，但内部重写了class方法，隐藏了该类的存在
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.person1 addObserver:self forKeyPath:@"age" options:options context:@"123"];
    
    [self printMethodNamesOfClass:object_getClass(self.person1)];
    [self printMethodNamesOfClass:object_getClass(self.person2)];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self.person1 setAge:21];
    
    [self.person1 willChangeValueForKey:@"age"];
    [self.person1 didChangeValueForKey:@"age"];
}

- (void)dealloc {
    [self.person1 removeObserver:self forKeyPath:@"age"];
}

// observeValueForKeyPath:ofObject:change:context:
// 当监听对象的属性值发生改变时，就会调用
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

@end
