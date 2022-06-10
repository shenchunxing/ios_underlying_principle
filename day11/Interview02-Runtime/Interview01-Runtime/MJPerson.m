//
//  MJPerson.m
//  Interview01-Runtime
//
//  Created by MJ Lee on 2018/5/17.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

//#define MJTallMask (1<<0)
//#define MJRichMask (1<<1)
//#define MJHandsomeMask (1<<2)

@interface MJPerson()
{
    // 结构体支持位域，这种写法比掩码要好
    struct {
        char tall : 1;//char是1个字节，但是指明：1说明只占1位
        char rich : 1;
        char handsome : 1;
    } _tallRichHandsome;
}
@end

@implementation MJPerson

- (void)setTall:(BOOL)tall
{
    _tallRichHandsome.tall = tall;
}

- (BOOL)isTall
{
    return !!_tallRichHandsome.tall; //这里！！取反是为了确保非0就是1，当前是1位，而bool类型需要1个字节，默认会用1111 1111 填充。导致显示-1
}

- (void)setRich:(BOOL)rich
{
    _tallRichHandsome.rich = rich;
}

- (BOOL)isRich
{
    return !!_tallRichHandsome.rich;
}

- (void)setHandsome:(BOOL)handsome
{
    _tallRichHandsome.handsome = handsome;
}

- (BOOL)isHandsome
{
    return !!_tallRichHandsome.handsome;
}

@end
