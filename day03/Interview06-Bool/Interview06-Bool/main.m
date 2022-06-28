//
//  main.m
//  Interview06-Bool
//
//  Created by 沈春兴 on 2022/6/28.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        _Bool x4 = 100; //C99定义的,值只有0和1,如果是被头文件stdbool.h包含,bool就定义为_Bool
        _Bool x5 = 1;
        _Bool x6 = 0;
        
        bool x1 = 100; //为布尔类型,C++里面定义的,值只有0和1。bool占一个字节.bool取值为true和false，是1和0的区别
        bool x2 = 2;
        bool x3 = 0;
        
        BOOL y1 = 100; //BOOL按照运行环境定义bool或者signed char类型，都是占用1个字节，得到的结果是YES NO
        BOOL y2 = 2;
        BOOL y3 = 0;
        short b1 = 8960;
        BOOL y4 = b1;
        
        Boolean z1 = 100;//Boolean占1个字节，unsigned char类型
        Boolean z2 = 2;
        Boolean z3 = 0;
        
        boolean_t a1 = 100; //boolean_t占4个字节，unsigned int类型
        boolean_t a2 = 2;
        boolean_t a3 = 0;
        
        NSLog(@"x1 = %d,x2 = %d ,x3 = %d",x1,x2,x3);
        NSLog(@"x4 = %d,x5 = %d ,x5 = %d",x4,x5,x6);
        NSLog(@"y1 = %d,y2 = %d ,y3 = %d,y4 = %d",y1,y2,y3,y4);
        NSLog(@"z1 = %d,z2 = %d ,z3 = %d",z1,z2,z3);
        NSLog(@"a1 = %d,a2 = %d ,a3 = %d",a1,a2,a3);
        
        //都是1个字节大小
        NSLog(@"%zd",sizeof(x1));
        NSLog(@"%zd",sizeof(x4));
        NSLog(@"%zd",sizeof(y1));
        NSLog(@"%zd",sizeof(z1));
        NSLog(@"%zd",sizeof(a1));
    }
    return 0;
}
