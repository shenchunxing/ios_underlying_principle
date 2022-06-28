//
//  main.m
//  Interview03-Category
//
//  Created by MJ Lee on 2018/5/3.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "MJPerson+Eat.h"
#import "MJPerson+Test.h"
#import "MJPerson.h"

//MARK: category的作用?
/**
 从架构上说，可以分门别类存放代码，增加代码的可读性，外部可以按需加载功能
 为已有的类做扩展，添加属性、方法、协议
 复写方法
 公开私有方法
 模拟多继承
 */

//MARK: category 的实现原理，如何被加载的?
/**
 category 编译完成的时候和类是分开的，在程序运行时才通过runtime合并在一起。
 _objc_init是Objcet-C runtime的入口函数，主要读取Mach-O文件完成OC的内存布局，以及初始化runtime相关数据结构。这个函数里会调用到两外两个函数，map_images和load_Images
 map_images追溯进去发现其内部调用了_read_images函数，_read_images会读取各种类及相关分类的信息。
 读取到相关的信息后通过addUnattchedCategoryForClass函数建立类和分类的关联。
 建立关联后通过remethodizeClass -> attachCategories重新规划方法列表、协议列表、属性列表，把分类的内容合并到主类
 在map_images处理完成后，开始load_images的流程。首先会调用prepare_load_methods做加载准备，这里面会通过schedule_class_load递归查找到NSObject然后从上往下调用类的load方法。
 处理完类的load方法后取出非懒加载的分类通过add_category_to_loadable_list添加到一个全局列表里
 最后调用call_load_methods调用分类的load函数
 */

//MARK: - load方法加载顺序
/**
 类的load方法在其父类load方法后执行
 分类的load方法在主类load方法后执行
 两个分类的load方法执行顺序遵循先编译先执行
 */

// MARK: - load、initialize方法的区别什么？在继承关系中他们有什么区别
/**
 load方法在运行时调用，加载类或分类的时候调用一次，继承关系参考load方法加载顺序。
 initialize在第一次自身或子类接受objc_msgSend消息的时候调用。如果子类没有实现initialize，会调用父类的。所以父类的initialize可能被调用多次
 load方法是直接通过方法调用地址调用的，initialize则是通过isa走位查找调用的
 load方法不会被覆盖，initialize可以覆盖
 */

// MARK: - category & extension区别，能给NSObject添加extension吗？
/**
 extension扩展是特殊的category，称为匿名分类或者私有分类，可以为类添加成员变量和方法。
 extension在编译期决议，category则是在运行时加载。
 extension一般用来隐藏私有信息，category可以公开私有信息
 无法给系统类添加extension，但是可以给系统类添加category
 extension可以添加成员变量，而category不可以
 extension和category都可以添加属性，但是category的属性不能自动生成成员变量、getter、setter
 */

// MARK: - 分类中添加实例变量和属性分别会发生什么，还是什么时候会发生问题？为什么
/**
 添加实例变量编译时报错。
 添加属性没问题，但是在运行的时候使用这个属性程序crash。原因是没有实例变量也没有set/get方法。
 可以通过关联对象去实现
 */

// MARK: - 分类中为什么不能添加成员变量（runtime除外）？
/**
 类对象在创建的时候已经定好了成员变量，但是分类是运行时加载的，无法添加。
 类对象里的 class_ro_t 类型的数据在运行期间不能改变，再添加方法和协议都是修改的 class_rw_t 的数据。
 分类添加方法、协议是把category中的方法，协议放在category_t结构体中，再拷贝到类对象里面。但是category_t里面没有成员变量列表。
 虽然category可以写上属性，其实是通过关联对象实现的，需要手动添加setter & getter。
 */

// MARK: - 分类可以添加那些内容
/**
 实例方法
 类方法
 协议
 属性
 */

// MARK: - 关联对象的实现和原理
/**
 关联对象不存储在关联对象本身内存中，而是存储在一个全局容器中；
 这个容器是由 AssociationsManager 管理并在它维护的一个单例 Hash 表AssociationsHashMap ；

 第一层 AssociationsHashMap：类名object ：bucket（map）
 第二层 ObjectAssociationMap：key（name）：ObjcAssociation（value和policy）
 
 AssociationsManager 使用 AssociationsManagerLock 自旋锁保证了线程安全。
 通过objc_setAssociatedObject给某对象添加关联值
 通过objc_getAssociatedObject获取某对象的关联值
 通过objc_removeAssociatedObjects移除某对象的关联值
 */

// MARK: - 使用关联对象，需要在主对象 dealloc 的时候手动释放么？
/**
 不需要，主对象通过 dealloc -> object_dispose -> object_remove_assocations 进行关联对象的释放
 */

void invokeOriginalMethod(id target , SEL selector) {
    uint count;
    Method *list = class_copyMethodList([target class], &count);
    for ( int i = count - 1 ; i >= 0; i--) {
        Method method = list[i];
        SEL name = method_getName(method);
        IMP imp = method_getImplementation(method);
        if (name == selector) {
            ((void (*)(id, SEL))imp)(target, name);
            break;
        }
    }
    free(list);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJPerson *person = [[MJPerson alloc] init];
        invokeOriginalMethod(person, @selector(run));
        
    }
    return 0;
}
