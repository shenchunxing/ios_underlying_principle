//
//  main.m
//  Interview02-class对象
//
//  Created by MJ Lee on 2018/4/8.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

//MARK:class_ro_t和class_rw_t的区别?
/**
 ObjC 类中的属性、方法还有遵循的协议等信息都保存在 class_rw_t 中，其中还有一个指向常量的指针 ro，其中存储了当前类在编译期就已经确定的属性、方法以及遵循的协议。
 */

//MARK:Runtime 的方法缓存？存储的形式、数据结构以及查找的过程？
/**
 缓存曾经调用过的方法，提高查找速率
     struct cache_t {
         struct bucket_t *_buckets; // 散列表
         mask_t _mask; //散列表的长度 - 1
         mask_t _occupied; // 已经缓存的方法数量，散列表的长度使大于已经缓存的数量的。
         //...
     }
     struct bucket_t {
         cache_key_t _key; //SEL作为Key @selector()
         IMP _imp; // 函数的内存地址
         //...
     }
     
     散列表的查找过程
      查询散列表，k
     bucket_t * cache_t::find(cache_key_t k, id receiver)
     {
         assert(k != 0); // 断言

         bucket_t *b = buckets(); // 获取散列表
         mask_t m = mask(); // 散列表长度 - 1
         mask_t begin = cache_hash(k, m); // & 操作
         mask_t i = begin; // 索引值
         do {
             if (b[i].key() == 0  ||  b[i].key() == k) {
                 return &b[i];
             }
         } while ((i = cache_next(i, m)) != begin);
         // i 的值最大等于mask,最小等于0。

         // hack
         Class cls = (Class)((uintptr_t)this - offsetof(objc_class, cache));
         cache_t::bad_cache(receiver, (SEL)k, cls);
     }
     上面是查询散列表函数，其中cache_hash(k, m)是静态内联方法，将传入的key和mask进行&操作返回uint32_t索引值。do-while循环查找过程，当发生冲突cache_next方法将索引值减1。
 */

// MARK: - C是动态运行时语言是什么意思？
/**
 动态类型：运行时确定对象的类型，编译时期能通过，但不代表运行过程中没有问题
 动态绑定：运行时才确定对象调用的方法（消息转发）
 动态加载：动态库的方法实现不拷贝到程序中，只记录引用，直到使用相关方法的时候才到库里面查找方法实现
 */

// MARK: - runtime能做什么？
/**
 获取类的成员变量、方法、协议
 为类添加成员变量、方法、协议
 动态改变方法实现
 */

// MARK: - class_copyIvarList与class_copyPropertyList的区别?
/**
 1、class_copyIvarList可以获取.h和.m中的所有属性以及@interface大括号中声明的变量，获取的属性名称有下划线(大括号中的除外)。
 2、class_copyPropertyList只能获取由@property声明的属性（包括.m），获取的属性名称不带下划线。
 */

// MARK: - 什么是 Method Swizzle（黑魔法），什么情况下会使用？
/**
 Method Swizzle 是改变一个已存在的选择器（SEL）对应的实现（IMP）的过程。
 类的方法列表存放着SEL的名字和IMP的映射关系。
 开发者可以利用 method_exchangeImplementations 来交换2个方法中的IMP
 开发者可以利用 method_setImplementation 来直接设置某个方法的IMP
 这就可以在运行时改变SEL和IMP的映射关系，从而实现方法替换。
 */

// MARK: - Method Swizzle注意事项
/**
 为了确保Swizzle Method方法替换一定被执行调用，可以在load中执行
 +load里面使用的时候不要调用[super load]。如果多次调用了[super load]，可能会出现“Swizzle无效”的假象
 避免调用[super load]导致Swizzling多次执行，在load中使用dispatch_once确保交换只被执行一次。
 子类替换没有实现的继承方法，会替换掉父类中的实现，影响父类及其他子嘞
 +initialize 里面使用要加dispatch_once
 进行版本迭代的时候需要进行一些检验，防止系统库的函数发生了变化
 */
// MARK: - 如何hook一个对象的方法，而不影响其它对象
/**
 方法1：新建一个子类重写方法
 方法2：让这个对象的类遵循某个协议，hook时判断。弊端是其他对象遵循了这个协议会受到影响。
 方法3：运行时创建一个新的子类，修改对象 isa 指针指向子类，hook 时使用isKindOf 判断类型
 */

// MARK: - 消息机制
/**
 1、快速查找，方法缓存
 2、慢速查找，方法列表
 3、消息转发
         3-1、方法的动态解析，resolveInstanceMethod
         3-2、快速消息转发，forwardingTargetForSelector
         3-3、标准消息转发，methodSignatureForSelector & forwardInvocation
 */

// MARK: - objc在向一个对象发送消息时，发生了什么？
/**
 方法调用实际上是发送消息，通过调用 objc_msgSend()实现的。
 首先，通过obj的isa指针找到对应的class。
 然后，开启快速查找流程。在class的缓存方法列表（objc_cache）里查找方法，如果找到就直接返回对应IMP。
 如果在缓存中找不到，开始慢速查找流程。在class的Method List查找对应方法，找到了返回对应IMP。
 都找不到就会走消息转发流程
 */

// MARK: - _objc_msgForward 函数是做什么的？
/**
 _objc_msgForward用于消息转发：向一个对象发送一条消息，但它并没有实现的时候，就调用_objc_msgForward尝试做消息转发。
 */

// MARK: - 为什么需要做方法缓存？
/**
 每次执行这个方法的时候都查一遍Method List太消耗性能。
 使用objc_cache把调用过的方法做一个缓存， 把method_name作为key， method_IMP作为value。
 下次接收到消息的时候，直接通过objc_cache去找到对应的IMP即可， 避免每一次都去遍历objc_method_list
 */

// MARK: - 一直都找不到方法怎么办？
/**
 会触发消息转发机制，我们一共有三次机会补救以防止crash
 方法的动态解析，通过resolveInstanceMethod添加一个IMP使其执行。
 快速消息转发，在 forwardingTargetForSelector返回一个可以执行该方法的对象。
 标准消息转发，methodSignatureForSelector创建相同方法类型的方法签名（NSMethodSignature），然后重写forwardInvocation并把拥有该签名的方法赋值到anInvocation.selector。
 */

// MARK: - 消息转发机制的优劣
/**
 优点：消息转发机制提供了找不到方法时的补救机会。
 缺点：一般情况下会在基类做crash处理，那么有可能把一部分的crash忽略过去导致无法暴露问题。
 */

// MARK: - IMP、SEL、Method的区别和使用场景
/**
 SEL相当于一个代号，方便查找方法的代号，处理通知/定时器等都会用到
 IMP是指向方法实现的指针，动态方法解析的时候会用到
 Method是一个对象，里面就存有SEL和IMP，消息转发流程获取方法签名的时候会用到
 */

@interface MJPerson : NSObject
{
    int _age;
    int _height;
    int _no;
}
@end

@implementation MJPerson
- (void)test {
    
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSObject *object1 = [[NSObject alloc] init];
        NSObject *object2 = [[NSObject alloc] init];
        
        Class objectClass1 = [object1 class];
        Class objectClass2 = [object2 class];
        Class objectClass3 = object_getClass(object1);
        Class objectClass4 = object_getClass(object2);
        Class objectClass5 = [NSObject class];
        
        NSLog(@"%p %p",
              object1,
              object2);
        
        NSLog(@"%p %p %p %p %p",
              objectClass1,
              objectClass2,
              objectClass3,
              objectClass4,
              objectClass5);
        
        NSLog(@"%lld",class_isMetaClass(object_getClass([MJPerson class]))); //元类
        NSLog(@"%lld",class_isMetaClass(object_getClass([NSObject class]))); //元类
    }
    return 0;
}
