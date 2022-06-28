//
//  main.m
//  Interview05-KVO
//
//  Created by 沈春兴 on 2022/6/28.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return 0;
}


//MARK:KVO原理
/**利用runtime动态生成一个子类。且让对象的isa指向新的子类。
 修改属性时，会调用Foundation的NSSetXXXValueAndNotify函数
 willchangevaluefor key;
 父类原来的setter
 didchangevalueforkey内部会触发observeValueForKeyPath:
 直接修改成员变量不会触发kvo，用kvc修改会触发。
**/

//MARK:通知和KVO的区别？
/**相同点：都是对象之间传递信息的一种机制 都能降低耦合性 。
   不同点：1.通知可以支持更广泛的系统事件包括属性更改，KVO 仅支持对象属性的更改，对于处理单纯的属性更改，KVO会更简单，一般用在框架中比较多 。2.通知使用交互的广播类型，会通过通知中心集中去分发，不需要接受对象注册通知功能就可以发送，同时还支持异步传递； KVO是点对点的交互模型，当属性改变的时候，向已经注册的观察者发送消息，同时是阻塞状态。3.通知使用名称标示，名称要具有唯一性 KVO是被观察者与观察者绑定，不会出现命名冲突

 由于这一系列的不同，所以在平常开发中，通知用得更多，而KVO主要是在自己写框架或者需要更精准获得对象属性变化的时候使用… 而手动开启一个KVO 就是常规手法了
**/

//MARK:KVO优点？
/**
 能够提供一种简单的方法实现两个对象的同步；
 能够对内部对象的状态改变作出响应，而且不需要改变内部对象的实现；
 能够提供被观察者属性的最新值和之前的值；
 使用key Path来观察属性，因此可以观察嵌套对象；
 完成了对观察对象的抽象，因为不需要额外的代码来允许观察者被观察。
 */
 
//MARK:KVO的缺点？
 /**
 1、我们观察的属性必须使用字符串来定义。因此在编译器不会出现警告以及类型检查；
 2、对属性重构将导致我们的观察代码不再可用
 3、复杂的“IF”语句要求对象正在观察多个值。这是因为所有的观察代码通过一个方法来指向；
 4、不支持block、体验不好、不灵活
 */

//MARK:如何对 NSMutableArray 进行 KVO？
/**
 -MutableArrayValueForKey:方法可以实现addObject和removeobject时触发kvo
 */

//MARK:哪些情况下使用kvo会崩溃，怎么防护崩溃?
/**
 removeObserver一个未注册的keyPath，导致错误：Cannot remove an observer A for the key path "str"，because it is not registered as an observer. 解决办法：根据实际情况，增加一个添加keyPath的标记，在dealloc中根据这个标记，删除观察者。

 添加的观察者已经销毁，但是并未移除这个观察者，当下次这个观察的keyPath发生变化时，kvo中的观察者的引用变成了野指针，导致crash。 解决办法：在观察者即将销毁的时候，先移除这个观察者
 其实还可以将观察者observer委托给另一个类去完成，这个类弱引用被观察者，当这个类销毁的时候，移除观察者对象，参考KVOController
 */
