//
//  main.m
//  Interview01-OC对象的本质
//
//  Created by MJ Lee on 2018/4/1.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

//struct NSObject_IMPL {
//    Class isa;
//};
//

//Student_IMPL 是 student的内部实现
struct Student_IMPL {
    Class isa;
    int _no;
    int _age;
};


@interface Student : NSObject
{
    //isa 8
    @public
    int _no; //4
    int _age; //4
}
@end

@implementation Student

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Student *stu = [[Student alloc] init];
        stu->_no = 4;
        stu->_age = 5;
        
        NSLog(@"%zd", class_getInstanceSize([Student class])); //16 = 8 + 4 + 4
        NSLog(@"%zd", malloc_size((__bridge const void *)stu)); //16
        
        
        struct Student_IMPL *stuImpl = (__bridge struct Student_IMPL *)stu; 
        NSLog(@"no is %d, age is %d", stuImpl->_no, stuImpl->_age);
    }
    return 0;
}
