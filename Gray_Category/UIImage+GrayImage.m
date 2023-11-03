//
//  UIColor+GrayColor.m
//
//
//

#import "UIImage+GrayImage.h"

@implementation UIImage (GrayImage)

+ (void)setAppGray {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            //交换方法
        Class cls = object_getClass(self);
        Method originMethod = class_getClassMethod(cls, @selector(imageNamed:));
        Method swizzledMethod = class_getClassMethod(cls, @selector(swizzled_imageNamed:));
        [self swizzleMethodWithOriginSel:@selector(imageNamed:) oriMethod:originMethod swizzledSel:@selector(swizzled_imageNamed:) swizzledMethod:swizzledMethod class:cls];

        Method originMethod1 = class_getClassMethod(cls, @selector(imageWithData:));
        Method swizzledMethod1 = class_getClassMethod(cls, @selector(swizzled_imageWithData:));
        [self swizzleMethodWithOriginSel:@selector(imageWithData:) oriMethod:originMethod1 swizzledSel:@selector(swizzled_imageWithData:) swizzledMethod:swizzledMethod1 class:cls];
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

+ (UIImage *)swizzled_imageWithData:(NSData *)data {
    UIImage *image = [self swizzled_imageWithData:data];
    return [image grayImage];
}

+ (UIImage *)swizzled_imageNamed:(NSString *)name {
    UIImage *image = [self swizzled_imageNamed:name];
    return [image grayImage];
}

// 转化灰度
- (UIImage *)grayImage {
    // 性能会更好一些
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
    int width = self.size.width;
    int height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}

@end
