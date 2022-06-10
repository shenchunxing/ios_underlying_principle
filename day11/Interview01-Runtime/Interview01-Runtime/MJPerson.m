//
//  MJPerson.m
//  Interview01-Runtime
//
//  Created by MJ Lee on 2018/5/17.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

// &可以用来取出特定的位

// 0000 0111
//&0000 0100
//------
// 0000 0100

// 掩码，一般用来按位与(&)运算的
//#define MJTallMask 1
//#define MJRichMask 2
//#define MJHandsomeMask 4

//#define MJTallMask 0b00000001
//#define MJRichMask 0b00000010
//#define MJHandsomeMask 0b00000100

#define MJTallMask (1<<0) //左移0位 也就是1
#define MJRichMask (1<<1) //左移1位 也就是2
#define MJHandsomeMask (1<<2)//左移2位 也就是4

@interface MJPerson()
{
    char _tallRichHansome; // 0b 0000 0011 //高富帅分别用1位来表示
}
@end

@implementation MJPerson


// 0010 1010
//&1111 1101
//----------
// 0010 1000

- (instancetype)init
{
    if (self = [super init]) {
        _tallRichHansome = 0b00000100;
    }
    return self;
}

- (void)setTall:(BOOL)tall
{
    if (tall) {
        _tallRichHansome |= MJTallMask;
    } else {
        _tallRichHansome &= ~MJTallMask;
    }
}

- (BOOL)isTall
{   //按位与
    return !!(_tallRichHansome & MJTallMask); //！！是为了转成bool类型（取反，再取反）
}

- (void)setRich:(BOOL)rich
{
    if (rich) {  //按位或，将rich位设为1，其他不变
        _tallRichHansome |= MJRichMask;
    } else { //按位或，将rich位设为0，其他不变 0b1111 1110
        _tallRichHansome &= ~MJRichMask;
    }
}

- (BOOL)isRich
{
    return !!(_tallRichHansome & MJRichMask);
}

- (void)setHandsome:(BOOL)handsome
{
    if (handsome) {
        _tallRichHansome |= MJHandsomeMask;
    } else {
        _tallRichHansome &= ~MJHandsomeMask;
    }
}

- (BOOL)isHandsome
{
    return !!(_tallRichHansome & MJHandsomeMask);
}

@end
