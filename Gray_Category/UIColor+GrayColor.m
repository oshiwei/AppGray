//
//  UIColor+GrayColor.m
//
// 
//

#import "UIColor+GrayColor.h"

@implementation UIColor (GrayColor)

+ (void)setAppGray {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = object_getClass(self);

        //将系统提供的colorWithRed:green:blue:alpha:替换掉
        Method originMethod = class_getClassMethod(cls, @selector(colorWithRed:green:blue:alpha:));
        Method swizzledMethod = class_getClassMethod(cls, @selector(swizzled_colorWithRed:green:blue:alpha:));
        [self swizzleMethodWithOriginSel:@selector(colorWithRed:green:blue:alpha:) oriMethod:originMethod swizzledSel:@selector(swizzled_colorWithRed:green:blue:alpha:) swizzledMethod:swizzledMethod class:cls];

        //将系统提供的colors也替换掉
        NSArray *array = [NSArray arrayWithObjects:@"redColor",@"greenColor",@"blueColor",@"cyanColor",@"yellowColor",@"magentaColor",@"orangeColor",@"purpleColor",@"brownColor",@"systemBlueColor",@"systemGreenColor", nil];

        for (int i = 0; i < array.count ; i ++) {
            SEL sel = NSSelectorFromString(array[i]);
            SEL swizzled_sel = NSSelectorFromString([NSString stringWithFormat:@"swizzled_%@",array[i]]);
            Method originMethod = class_getClassMethod(cls, sel);
            Method swizzledMethod = class_getClassMethod(cls, swizzled_sel);
            [self swizzleMethodWithOriginSel:sel oriMethod:originMethod swizzledSel:swizzled_sel swizzledMethod:swizzledMethod class:cls];
        }
    });
}

+ (void)swizzleMethodWithOriginSel:(SEL)oriSel
                         oriMethod:(Method)oriMethod
                       swizzledSel:(SEL)swizzledSel
                    swizzledMethod:(Method)swizzledMethod
                             class:(Class)cls {
    BOOL didAddMethod = class_addMethod(cls, oriSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSel, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, swizzledMethod);
    }
}

+ (UIColor *)swizzled_redColor {
    // 1.0, 0.0, 0.0 RGB
    UIColor *color = [self swizzled_redColor];
    color = [self changeGrayWithColor:color Red:1.0 green:0.0 blue:0.0 alpha:1.0];
    return color;
}

+ (UIColor *)swizzled_greenColor {
     // 0.0, 1.0, 0.0 RGB
    UIColor *color = [self swizzled_greenColor];
    color = [self changeGrayWithColor:color Red:0.0 green:1.0 blue:0.0 alpha:1.0];
    return color;
}

+ (UIColor *)swizzled_blueColor {
    //0.0, 0.0, 1.0
    UIColor *color = [self swizzled_blueColor];
    color = [self changeGrayWithColor:color Red:0.0 green:0.0 blue:1.0 alpha:1.0];
    return color;
}

+ (UIColor *)swizzled_cyanColor {
    // 0.0, 1.0, 1.0
    UIColor *color = [self swizzled_cyanColor];
    color = [self changeGrayWithColor:color Red:0.0 green:1.0 blue:1.0 alpha:1.0];
    return color;
}

+ (UIColor *)swizzled_yellowColor {
    //1.0, 1.0, 0.0
    UIColor *color = [self swizzled_yellowColor];
    color = [self changeGrayWithColor:color Red:1.0 green:1.0 blue:0.0 alpha:1.0];
    return color;
}

+ (UIColor *)swizzled_magentaColor {
    // 1.0, 0.0, 1.0
    UIColor *color = [self swizzled_magentaColor];
    color = [self changeGrayWithColor:color Red:1.0 green:0.0 blue:1.0 alpha:1.0];
    return color;
}

+ (UIColor *)swizzled_orangeColor {
    // 1.0, 0.5, 0.0
    UIColor *color = [self swizzled_orangeColor];
    color = [self changeGrayWithColor:color Red:1.0 green:0.5 blue:0.0 alpha:1.0];
    return color;
}

+ (UIColor *)swizzled_systemBlueColor {
    UIColor *color = [self swizzled_systemBlueColor];
    color = [self changeGrayWithColor:color Red:0.0 green:0.0 blue:1.0 alpha:1.0];
    return color;
}

+ (UIColor *)swizzled_systemGreenColor {
    UIColor *color = [self swizzled_systemGreenColor];
    color = [self changeGrayWithColor:color Red:0.0 green:1.0 blue:0.0 alpha:1.0];
    return color;
}

+ (UIColor *)swizzled_purpleColor {
    // 0.5, 0.0, 0.5
    UIColor *color = [self swizzled_purpleColor];
    color = [self changeGrayWithColor:color Red:0.5 green:0.0 blue:0.5 alpha:1.0];
    return color;
}

+ (UIColor *)swizzled_brownColor {
    // 0.6, 0.4, 0.2
    UIColor *color = [self swizzled_brownColor];
    color = [self changeGrayWithColor:color Red:0.6 green:0.4 blue:0.2 alpha:1.0];
    return color;
}

+ (instancetype)swizzled_colorWithRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a {
    
    UIColor *color = [self swizzled_colorWithRed:r green:g blue:b alpha:a];
    if (r == 0 && g == 0 && b == 0) {
        return color;
    }
    color = [self changeGrayWithColor:color Red:r green:g blue:b alpha:a];
    return  color;
}

+ (UIColor *)changeGrayWithColor:(UIColor *)color Red:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a {
    CGFloat gray = r * 0.299 +g * 0.587 + b * 0.114;
    UIColor *grayColor = [UIColor colorWithWhite:gray alpha:a];
    return  grayColor;
}


@end
