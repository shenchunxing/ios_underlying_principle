//
//  ViewController.m
//  Interview19-卡顿优化
//
//  Created by MJ Lee on 2018/7/3.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) UIImageView *imageView;
@end

@implementation ViewController

// MARK: - 屏幕撕裂的原因 ,如何解决？
/**
 单一缓存模式下，帧缓冲区只有一个缓存空间
 图片需要经过CPU -> 内存 -> GPU -> 展示 的渲染过程
 CPU和GPU的协作过程中出现了偏差，GPU应该完整的绘制图片，但是工作慢了只绘制出图片上半部分。
 此时CPU又把新数据存储到缓冲区，GPU继续绘制的时候下半部分就变成了新数据。
 造成了两帧同时出现了一部分在屏幕上，看起来就撕裂了。
 
 解决上一帧和下一帧的覆盖问题，需要使用不同的缓冲区，通过两个图形缓冲区的交替来解决。
 出现速度差的时候，就把下一帧存储在后备缓冲区，绘制完成后再切换帧。
 当绘制完最后一个像素点就会发出这个垂直同步信号通知展示完成。
 所以屏幕撕裂问题需要通过 双缓冲区 + 垂直同步信号 解决。
 */

// MARK: - 掉帧是怎么产生的？怎么解决？
/**
 屏幕正在展示A帧的时候，CPU和GPU会处理B帧。
 A帧展示完成该切换展示B帧的时候B帧的数据未准备好。
 没办法切换就只能重复展示A帧，感官上就是卡了，这就是掉帧的问题
 
 掉帧根本原因是CPU和GPU渲染计算耗时过长
 1、降低视图层级
 2、提前或减少在渲染期的计算
 */

// MARK: - CPU渲染职能
/**
 布局计算：如果视图层级过于复杂，当试图呈现或者修改的时候，计算图层帧率就会消耗一部分时间，
 视图懒加载： iOS只会当视图控制器的视图显示到屏幕上才会加载它，这对内存使用和程序启动时间很有好处，但是当呈现到屏幕之前，按下按钮导致的许多工作都不会被及时响应。比如，控制器从数据局中获取数据， 或者视图从一个xib加载，或者涉及iO图片显示都会比CPU正常操作慢得多。
 解压图片：PNG或者JPEG压缩之后的图片文件会比同质量的位图小得多。但是在图片绘制到屏幕上之前，必须把它扩展成完整的未解压的尺寸(通常等同于图片宽 x 长 x 4个字节)。为了节省内存，iOS通常直到真正绘制的时候才去解码图片。根据你加载图片的方式，第一次对图层内容赋值的时候(直接或者间接使用 UIImageView )或者把它绘制到Core Graphics中，都需要对它解压，这样的话，对于一个较大的图片，都会占用一定的时间。
 Core Graphics绘制：如果对视图实现了drawRect:或drawLayer:inContext:方法，或者 CALayerDelegate 的方法，那么在绘制任何东西之前都会产生一个巨大的性能开销。为了支持对图层内容的任意绘制，Core Animation必须创建一个内存中等大小的寄宿图片。然后一旦绘制结束之后， 必须把图片数据通过IPC传到渲染服务器。在此基础上，Core Graphics绘制就会变得十分缓慢，所以在一个对性能十分挑剔的场景下这样做十分不好。
 图层打包：当图层被成功打包，发送到渲染服务器之后，CPU仍然要做如下工作:为了显示 屏幕上的图层，Core Animation必须对渲染树种的每个可见图层通过OpenGL循环转换成纹理三角板。由于GPU并不知晓Core Animation图层的任何结构，所以必须要由CPU做这些事情。这里CPU涉及的工作和图层个数成正比，所以如果在你的层 级关系中有太多的图层，就会导致CPU没一帧的渲染，即使这些事情不是你的应用 程序可控的。
 */

// MARK: - GPU渲染职能
/**
 GPU会根据生成的前后帧缓存数据，根据实际情况进行合成，其中造成GPU渲染负担的一般是：离屏渲染，图层混合，延迟加载。
 */

// MARK: - 一个UIImageView添加到视图上以后，内部如何渲染到手机上的？
/**
 图片显示分为三个步骤： 加载、解码、渲染
 通常，我们程序员的操作只是加载，至于解码和渲染是由UIKit内部进行的。
 例如：UIImageView显示在屏幕上的时候需要UIImage对象进行数据源的赋值。而UIImage持有的数据是未解码的压缩数据，当赋值的时候，图像数据会被解码变成RGB颜色数据，最终渲染到屏幕上。
 */

// MARK: - 说说渲染流程
/**
 1、CPU确定绘制图形的位置，拿到iOS的系统坐标，需要换算成屏幕坐标系。
 2、转换后确定好顶点的位置，这时候就需要图元装配，这个就是确定顶点间的连线关系。
 3、确定连接方式以后需要进行光栅化，就是把展示用到的像素点摘出来。
 4、摘出来以后GPU进行片元着色器处理，计算摘出来的像素点展示的颜色，并存入缓冲区。
 5、屏幕展示
 */

// MARK: - 什么是离屏渲染 ? 离屏渲染的影响 ? 什么操作会触发离屏渲染?
/**
 普通渲染流程：APP - 帧缓冲区 - 展示
 离屏渲染流程：APP - 离屏渲染缓冲区 - 帧缓冲区 - 展示
 离屏渲染，是无法一次性处理渲染，需要分部处理并存储中间结果引起的。
 所以判断是否出现离屏渲染的根本条件就是判断渲染是否需要分部处理～
 需要分步处理，会产生离屏渲染
 一次性渲染，不产生离屏渲染
 
 
 需要分几步就需要开辟出几个离屏渲染缓冲区存储中间结果，造成空间浪费。
 最后合并多个离屏渲染缓冲区才能展示结果，会影响性能。
 
 
 光栅化 layer.shouldRasterize = YES
 遮罩layer.mask
 圆角layer.maskToBounds = Yes，Layer.cornerRadis
 阴影layer.shadowXXX

 */

// MARK: - AutoLayout的原理，性能如何? 自动布局怎么实现的?
/**
 Auto Layout 只关注视图之间的关系，通过布局引擎和已有的约束计算出各个视图的frame
 每当约束改变时会重新计算各个视图的frame
 获得frame的过程，就是根据各个视图已有的约束条件解方程式的过程。
 性能会随着视图数量的增加呈指数级增加
 达到一定数量的视图时，布局所需要的时间就会大于16.67ms，超过屏幕的刷新频率时会出现卡顿。

 原理是线性公式，使用了系统提供的NSLayoutConstraint
 Masonry基于它封装
 */

// MARK: - ViewController生命周期
/**
 initWithCoder：通过nib文件初始化时触发。
 awakeFromNib：nib文件被加载的时候，会发生一个awakeFromNib的消息到nib文件中的每个对象。
 loadView：开始加载视图控制器自带的view。
 viewDidLoad：视图控制器的view被加载完成。
 viewWillAppear：视图控制器的view将要显示在window上。
 updateViewConstrains：视图控制器的view开始更新AutoLayout约束。
 viewWillLayoutSubviews：视图控制器的view将要更新内容视图的位置。
 viewDidLayoutSubviews：视图控制器的view已经更新视图的位置。
 viewDidAppear：视图控制器的view已经展示到window上。
 viewWillDisappear：视图控制器的view将要从window上消失。
 viewDidDisappear：视图控制器的view已经从window上消失。
 */

// MARK: - LayoutSubviews调用时机
/**
 init 初始化不会调用 LayoutSubviews 方法
 addsubView 时候会调用
 改变一个 view 的 frame 的时候调用
 滚动 UIScrollView 导致 UIView 重新布局的时候会调用
 手动调用 setNeedsLayout 或者 layoutIfNeeded
 */

// MARK: - layoutIfNeeded和setNeedsLayout的区别
/**
 setNeedsLayout 标记为需要重新布局

 异步调用layoutIfNeeded刷新布局，不立即刷新，在下一轮runloop结束前刷新。
 对于这一轮runloop之内的所有布局和UI上的更新只会刷新一次，layoutSubviews一定会被调用。


 layoutIfNeeded

 如果有需要刷新的标记，立即调用layoutSubviews进行布局
 如果没有标记，不会调用layoutSubviews
 如果想在当前runloop中立即刷新，调用顺序应该是

 [self setNeedsLayout];
 [self layoutIfNeeded];
 */

// MARK: - drawRect调用时机
/**
 drawRect在loadView和ViewDidLoad之后调用
 */

// MARK: - UIView和CALayer是什么关系?
/**
 View可以响应并处理用户事件，CALayer 不可以。
 每个 UIView 内部都有一个 CALayer 提供尺寸样式（模型树），进行绘制和显示。
 两者都有树状层级结构，layer 内部有 subLayers，view 内部有 subViews。
 CALayer是支持隐式动画的，View 作为Layer的代理，通过 actionForLayer:forKey:向Layer提交相应的动画
 layer 内部维护着三个 layer tree

 动画树presentLayer Tree，修改动画的属性改的是动画树的属性值
 模型树modeLayer Tree，最终展示在界面上的其实是提供视图的模型树
 渲染树render Tree。
 */

// MARK: - UIView显示原理
/**
 UIView 可以显示是因为内部有一个layer作为根图层，根图层上可以放其他子图层。
 UIView 中所有能够看到的内容都包含在layer中
 当UIView需要显示到屏幕上会调用drawRect:方法进行绘图，并且会将所有内容绘制在自己的layer上
 绘图完毕后，系统将图层展示到屏幕上，完成了UIView的显示。
 */

// MARK: - UIView显示过程
/**
 view.layer创建一个图层类型的上下文（Layer Graphics Contex）
 view.layer.delegate，也就是view，调用drawLayer:inContext:方法，并传入刚才准备好的上下文
 drawLayer:inContext:内部会让view调用drawRect:方法绘图
 开发者在drawRect:方法中实现绘图代码, 所有东西最终都绘制到view.layer上面
 系统将view.layer的内容展示 到屏幕, 于是完成了view的显示
 */

// MARK: - UITableView卡顿的的原因有哪些？
/**
 隐式绘制 CGContext
 文本CATextLayer 和 UILabel
 光栅化 shouldRasterize
 离屏渲染
 可伸缩图片
 shadowPath
 混合和过度绘制
 减少图层数量
 裁切
 对象回收
 Core Graphics绘制
 -renderInContext: 方法
 */

// MARK: - UITableVIew优化
/**
 重用机制（缓存池）
 少用有透明度的View
 尽量避免使用xib
 尽量避免过多的层级结构
 iOS8以后出的预估高度
 减少离屏渲染操作（圆角、阴影）
 缓存cell的高度（提前计算好cell的高度，缓存进当前的模型里面）
 异步绘制
 滑动的时候，按需加载
 尽量少add、remove 子控件，最好通过hidden控制显示
 */

// MARK: - imageName与imageWithContentsOfFile区别？
/**
 imageWithContentsOfFile：加载本地目录图片，不能加载image.xcassets里面的图片资源。不缓存占用内存小，相同的图片会被重复加载到内存中。不需要重复读取的时候使用。
 imageNamed：可以读取image.xcassets的图片资源，加载到内存缓存起来，占用内存较大，相同的图片不会被重复加载。直到收到内存警告的时候才会释放不使用的UIImage。需要重复读取同一个图片的时候用。
 */

// MARK: - UIScrollerView实现原理
/**
 滚动其实是在修改原点坐标。当手指触摸后，scrollview拦截触摸事件创建一个计时器。
 如果计时器到点后没有发生手指移动事件，scrollview 发送 tracking events 到被点击的 subview。
 如果计时器到点前发生了移动事件， scrollview 取消 tracking 自己滚动。
 */

// MARK: - 什么是响应链？ 事件响应链？
/**
 由链接在一起的响应者（UIResponse及其子类）组成的链式关系。
 最先的响应者称为第一响应者
 最底层的响应者是UIApplication
 
 subView -> view -> superView -> viewController -> window -> application
 */

// MARK: - 什么是事件传递？ 事件传递的过程？
/**
 触发事件后，事件从第一响应者到application的传递过程
 
 当程序中发生触摸事件之后，系统会将事件添加到UIApplication管理的一个队列当中
 application将任务队列的首个任务向下分发
 application -> window -> viewController -> view
 view需要满足条件才可以处理任务，透明度>0.01、触摸在view的区域内、userInteractionEnabled=YES、hidden=NO。
 满足条件的view遍历自身的subViews，判断是否满足上述条件
 如果所有subView都无法满足条件，那么最佳响应者就是自己。
 如果没有任何一个view能处理事件，事件会被废弃。
 */

// MARK: - 找出触摸的View？ 自定义响应者？
/**
 // 返回的View是本次点击的最佳响应者
 - (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
 ​
 // 判断点是否落在某区域
 - (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
 
 //自定义响应者
 - (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // 1.判断当前控件能否接收事件
    if (self.userInteractionEnabled == NO ||
        self.hidden == YES ||
        self.alpha <= 0.01) {
         return nil;
     }
    // 2. 判断点在不在当前控件
    if ([self pointInside:point withEvent:event] == NO) {
         return nil;
    }
    // 3.从后往前遍历自己的子控件
    NSInteger count = self.subviews.count;
    for (NSInteger i = count - 1; i >= 0; i--) {
       UIView *childView = self.subviews[I];
       // 把当前控件上的坐标系转换成子控件上的坐标系
       CGPoint childP = [self convertPoint:point toView:childView];
       UIView *fitView = [childView hitTest:childP withEvent:event];
        if (fitView) { // 寻找到最合适的view
            return fitView;
        }
    }
    // 循环结束 没有比自己更合适的view
    return self;
 }


 */

// MARK: - 常见Crash的原因有哪些？
/**
 1、找不到方法的实现 unrecognized selector sent to instance
 2、KVC造成的crash
 3、KVO造成的crash
 4、EXC_BAD_ACCESS
 5、集合类相关崩溃，越界等
 6、多线程中的崩溃，使用了被释放的对象
 7、后台返回错误的数据结构
 */

// MARK: - 优化启动时间
/**
 mian函数之前的启动优化

 减少或合并动态库（这是目前为止最耗时的了， 基本上占了95%以上的时间）
 确认动态库是optional or required。如果该Framework在支持的所有iOS系统版本都存在，那么就设为required，否则就设为optional，因为optional会有些额外的检查
 
 mian函数之后的启动优化 首先分析一下从main函数开始执行，到第一个页面显示， 这段时间做了哪些事情
 1、减少创建线程，线程创建和运行平均消耗大约在 29 毫秒，这是很大的时间开销。若在应用启动时开启多个线程，则尤为明显。线程的启动时间之所以如此之长，是因为多次的上下文切换所带来的开销。所以线程在开发过程中也避免滥用
 2、编译器插桩获取方法符号，生成order file设置到xcode。减少页中断带来的耗时。
 3、合并或者删减不必要的类或者分类
 4、将不必需在+load方法中做的事情，延时放到+initialize。
 5、 SDK 和配置事件，由于启动时间不是必须的，所以我们可以放在第一个界面的 viewDidAppear 方法里
 */

// MARK: - 网络优化
/**
 IP直连，将我们原本的请求链接www.baidu.com 修改为 180.149.132.47
 运营商在拿到请求后发现是IP地址会直接放行，而不会去走DNS解析
 不走他的DNS解析也就不会存在DNS被劫持的问题
 实现方法1：直接使用HTTPDNS等sdk
 实现方法2：服务端下发发域名-IP对应列表，客户端缓存，通过缓存IP来进行业务访问。
 */

// MARK: - 包体积优化
/**
 1、删除陈旧代码、删除陈旧xib/sb，删除无用的资源文件（检测未使用图片的工具LSUnusedResources）
 2、图片、音视频资源压缩后使用。
 3、动图可以使用webP格式，加载速度比较慢，但体积小
 4、能用动态库的尽量用动态库，一般情况静态库的体积会比动态库大
 5、主题类的资源文件提供按需下载功能，不直接打包在应用包里面
 6、App Slicing，应用程序切片，只打包下载机型所需的资源文件，不需要开发者处理
 7、Bitcode，中间代码， 苹果会对可执行文件进行优化，不需要开发者处理
 8、ODR，On Demand Resources，按需加载资源，需要开发者处理
 */

// MARK: - 电量优化
/**
 1.定位，尽量不要实时更新，可以适当降低精度
 2.网络请求，能用缓存的时候尽量使用缓存，降低请求的频率，减少请求的次数，优化传输结构
 3.CPU处理，需要复用的数据能缓存的数据尽量缓存，优化算法和数据结构
 4.GPU处理，减少离屏渲染
 */

// MARK: - 编译链接流程
/**
 0、输入文件：找到源文件
 1、预处理：包括替换宏和导入头文件
 2、编译阶段：词法分析、语法分析、语义分析，最终生成IR
     2-1、预处理后会进行词法分析，词法分析会把代码切片成一个个token。
     2-2、语法分析会验证语法是否正确，在词法分析的基础上把单词组合成各种语法短语，然后把节点组成抽象的语法树
     2-3、代码生成器根据语法树自顶向下生成LLVM IR。OC会在这里进行runtime的桥接：property的合成、ARC处理等
 3、编译器后端：通过一个个Pass去优化，每个Pass完成一部分功能，最终生成汇编代码
     3-1、苹果对代码做了进一步优化，并且通过.ll文件生成.bc文件。
     3-2、可以通过.bc或.ll文件生成汇编代码
 4、生成目标文件，.o格式的目标文件
 5、链链接需要的动态库和静态库
 6、通过不同架构，生成对应的可执行文件MachO
 */

// MARK: - APP启动过程
/**
 1、加载可执行文件（读取Mach-O）
 2、加载动态库（Dylib）
 3、Rebase & Bind
     3-1、Rebase的作用是修正ASLR的偏移，把当前MachO的指针指向正确的内存
     3-2、Bind的作用是重新修复外部方法指针的指向，fishhook原理
 4、Objc，加载类和分类那套
 5、Initializers，调用load方法，初始化C & C++的对象等
 6、main()函数
 7、执行AppDelegate的代理方法（如：didFinishLaunchingWithOptions）。
 8、初始化Windows，初始化ViewController。
 */

// MARK: - dyld做了什么
/**
 1、dyld读取Mach-O的Header和Load Commands
 2、找可执行文件的依赖动态库，将依赖的动态库加载到内存中。这是一个递归的过程，依赖的动态库可能还会依赖别的动态库，所以dyld会递归每个动态库，直至所有的依赖库都被加载完毕。
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self image];
    
    
//    self.view.frame = CGRectMake(0, 0, 100, 100);
    
//    self.view.frame = CGRectMake(1, 0, 100, 100);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)text
{
    // 文字计算
    [@"text" boundingRectWithSize:CGSizeMake(100, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil];
    
    // 文字绘制
    [@"text" drawWithRect:CGRectMake(0, 0, 100, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil];
}

- (void)image
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(100, 100, 100, 56);
    [self.view addSubview:imageView];
    self.imageView = imageView;

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 获取CGImage
        CGImageRef cgImage = [UIImage imageNamed:@"timg"].CGImage;

        // alphaInfo
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }

        // bitmapInfo
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;

        // size
        size_t width = CGImageGetWidth(cgImage);
        size_t height = CGImageGetHeight(cgImage);

        // context
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo);

        // draw
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);

        // get CGImage
        cgImage = CGBitmapContextCreateImage(context);

        // into UIImage
        UIImage *newImage = [UIImage imageWithCGImage:cgImage];

        // release
        CGContextRelease(context);
        CGImageRelease(cgImage);

        // back to the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = newImage;
        });
    });
}

@end
