//
//  ViewController.m
//  Interview05-TaggedPointer面试题
//
//  Created by MJ Lee on 2018/6/21.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

#define MDMLog(str) ({NSString *name = @#str; NSLog(@"%@-->%@ %p, %zd", name, [str class], str, CFGetRetainCount((__bridge CFTypeRef)str));})

@interface ViewController ()
@property (nonatomic, strong) NSString *strongString;
@property (nonatomic, weak) NSString *weakString;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self test1];
    NSLog(@"---------------");
    [self test2];
    NSLog(@"---------------");
    [self test3];
}

- (void)test1 {
    //字面量
    NSString *str1 = @"123456789"; //0x100c15040 __NSCFConstantString 引用计数：105553131410848
    MDMLog(str1);
    //+ stringWithString:
    NSString *str2 = [NSString stringWithString:@"123456789"];//0x100c15040 __NSCFConstantString 引用计数：105553131395712
    MDMLog(str2);
    //+ stringWithFormat:
    NSString *str3 = [NSString stringWithFormat:@"123456789"]; //0x8332bd8e7dfd3e53 NSTaggedPointerString 引用计数：105553131395744
    MDMLog(str3);
    //- initWithString:
    NSString *str4 = [[NSString alloc] initWithString:@"123456789"]; //0x100c15040 __NSCFConstantString 引用计数：105553131411232
    MDMLog(str4);
    //- initWithFormat:
    NSString *str5 = [[NSString alloc] initWithFormat:@"123456789"]; //0x8332bd8e7dfd3e53 NSTaggedPointerString  引用计数：105553131396096
    MDMLog(str5);
    
    
    //包含ASCII码之外的字符   __NSCFString
    NSString *str6 = [[NSString alloc] initWithFormat:@"马"];
    MDMLog(str6); //1
    
//只包含ASCII码中的字符
    //字符串长度在0-7之间 NSTaggedPointerString
    NSString *str7 = [[NSString alloc] initWithFormat:@"1234567"];
    MDMLog(str7);
    
    //字符串长度在8-9之间  NSTaggedPointerString
    NSString *str8 = [[NSString alloc] initWithFormat:@"abcdefgh"];
    MDMLog(str8);
    
    //字符串长度在10-11之间 NSTaggedPointerString
    NSString *str9 = [[NSString alloc] initWithFormat:@"acdefghijk"];
    MDMLog(str9);

    
    //字符串长度>11 __NSCFString
    NSString *str10 = [[NSString alloc] initWithFormat:@"aaaaaaaaaaaa"];
    MDMLog(str10); //1
    
    /**
     当使用字符串常量生成NSString对象，例如字面量、+ stringWithString:、- initWithString:方法时，生成的NSString对象为__NSCFConstantString类型，且计数为整数最大值，并一直存在于内存中。
     当使用格式化字符且字符中包含非ASCII字符生成NSString对象，例如+ stringWithFormat:、- initWithFormat:时。生成的NSString为__NSCFString类型，且遵循引用计数规则。
     当使用格式化字符且只包含ASCII字符生成NSString对象时：

     字符数在0-7之间，生成NSTaggedPointerString对象并计数为整数最大值且一直存在内存中。
     字符数在8-9时，字符全部在6位编码表中时，生成NSTaggedPointerString对象并计数为整数最大值且一直存在内存中。
     字符数在8-9时，字符存在不在6位编码表中时，生成的NSString为__NSCFString类型，且遵循引用计数规则。
     字符数在10-11时，字符全部在5位编码表中时，生成NSTaggedPointerString对象并计数为整数最大值且一直存在内存中。
     字符数在10-11时，字符存在不在5位编码表中时，生成的NSString为__NSCFString类型，且遵循引用计数规则。
     字符数大于11时，生成的NSString为__NSCFString类型，且遵循引用计数规则。
     */
    
    
    //NSString类簇
    NSLog(@"__NSCFConstantString.superClass = %@",[NSClassFromString(@"__NSCFConstantString") superclass]);//__NSCFString
    NSLog(@"NSTaggedPointerString.superClass = %@",[NSClassFromString(@"NSTaggedPointerString") superclass]);//NSString
    NSLog(@"__NSCFString.superClass = %@",[NSClassFromString(@"__NSCFString") superclass]);//NSMutableString
    NSLog(@"NSString.superClass = %@" , [NSClassFromString(@"NSString") superclass]);//NSObject
    NSLog(@"NSString 的所有子类 = %@" , [self findSubClass:[NSString class]]);
    /**
     NSString,
     PLUUIDString,
     "__NSATSStringSegment",
     VKInternedString,
     INDeferredLocalizedString,
     UNLocalizedString,
     CSLocalizedString,
     ACZeroingString,
     "_PASProxyConcatenatedString",
     "_CPBundleIdentifierString",
     "_PFAbstractString",
     NSLocalizableString,
     "__NSCFLocalizedAttributedString",
     NSPinyinString,
     "_NSClStr",
     "_NSStringProxyForContext",
     NSSimpleCString,
     NSDebugString,
     "__NSVariableWidthString",
     NSPathStore2,
     NSPlaceholderString,
     NSTaggedPointerString,
     NSMutableString
     */
    
    NSLog(@"-----------------");
    
    //NSArray
    NSLog(@"NSArray.superClass = %@",[NSArray superclass]); //NSObject
    NSLog(@"NSMutableArray.superClass = %@",[NSMutableArray superclass]);//NSArray
    NSLog(@"NSArray 的所有子类 = %@" , [self findSubClass:[NSArray class]]);
    /**
     NSArray,
     WKNSArray,
     AVFragmentedAssetsArray,
     CMStrideCalibrationEntryArray,
     CMGyroDataArray,
     CMAmbientPressureDataArray,
     CMAccelerometerDataArray,
     MLSequnceAsFeatureValueArray,
     MLMultiArrayAsNSArrayWrapper,
     "_CTFontFallbacksArray",
     CSSearchableItemCodedArray,
     "_PASLazyArrayBase",
     "_PFResultArray",
     "_PFEncodedArray",
     "_PFBatchFaultingArray",
     "_PFArray",
     "_NSCallStackArray",
     "_NSMetadataQueryResultGroupArray",
     "_NSMetadataQueryResultArray",
     NSKeyValueArray,
     "__NSArrayReversed",
     "__NSOrderedSetArrayProxy",
     CALayerArray,
     "__NSFrozenArrayM",
     "__NSArrayI_Transfer",
     "__NSArrayI",
     "__NSSingleObjectArrayI",
     "_NSConstantArray",
     NSConstantArray,
     NSMutableArray,
     "__NSArray0"
     */
    
    NSLog(@"---------------------------------------------------------------");
    
    //NSNumber
    NSLog(@"NSNumber.superClass = %@",[NSNumber superclass]); //NSValue
    NSLog(@"NSNumber 的所有子类 = %@" , [self findSubClass:[NSNumber class]]);
    /**
     NSNumber,
     WKNSNumber,
     "_PFCachedNumber",
     ICSPredefinedValue,
     NSDecimalNumber,
     NSPlaceholderValue,
     "__NSCFNumber",
     "__NSCFBoolean",
     "_NSConstantNumber",
     NSConstantDoubleNumber,
     NSConstantFloatNumber,
     NSConstantIntegerNumber
     */
}

- (void)test2 {
    self.strongString =  [NSString stringWithFormat:@"%@",@"string1"]; //autorelease形式释放的,这个字符串对象是NSTaggedPointerString类型，是一个常量，不受arc管理。不会被释放
    MDMLog( self.strongString);
    self.weakString =  self.strongString;
    self.strongString = nil; //即使self.strongString置为空，还有self.weakString对字符串对象的引用，所以打印出来还是字符串对象
    MDMLog(self.weakString);
    NSLog(@"%@", self.weakString);
}

- (void)test3 {
    //常量字符串，str和str1是同一个对象，引用计数为2
    NSString *str = [[NSString alloc] initWithFormat:@"牛"];//1
    MDMLog(str);
    NSString *str1 = [str copy];//2
    
    MDMLog(str);
    MDMLog(str1);
    
    
    //可变到不可变，创建了新对象，引用计数为1
    NSString *str2 = [[NSMutableString alloc] initWithString:@"牛"];//1
    MDMLog(str2);
    NSString *str3 = [str2 copy];//1
    
    MDMLog(str2);
    MDMLog(str3);
}

//获取指定类的子类
- (NSArray *)findSubClass:(Class)defaultClass {
    //注册类的总数
    int count = objc_getClassList(NULL,0);
    //创建一个数组，其中包含给定对象
    NSMutableArray * array = [NSMutableArray arrayWithObject:defaultClass];
    //获取所有已注册的类
    Class *classes = (Class *)malloc(sizeof(Class) * count);
    
    objc_getClassList(classes, count);
    
    //遍历
    for (int i = 0; i < count; i++) {
        
        if (defaultClass == class_getSuperclass(classes[i])) {
            
            [array addObject:classes[i]];
            
        }
        
    }
    
    free(classes);
    return array;
    
}

@end
