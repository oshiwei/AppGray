//
//  IMYAppGrayStyle.m
//  IMYAppGrayStyle
//
//  Created by ljh on 2022/1/27.
//

#import "IMYAppGrayStyle.h"

@interface IMYAppGrayStyleCoverView : UIView

@end

@implementation IMYAppGrayStyleCoverView

+ (NSHashTable *)allCoverViews {
    static NSHashTable *array;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = [NSHashTable weakObjectsHashTable];
    });
    return array;
}

+ (void)showInMaskerView:(UIView *)maskerView {
    if (@available(iOS 13, *)) {
        // 遍历是否已添加 gray cover view
        for (UIView *subview in maskerView.subviews) {
            if ([subview isKindOfClass:IMYAppGrayStyleCoverView.class]) {
                return;
            }
        }
        
        IMYAppGrayStyleCoverView *coverView = [[self alloc] initWithFrame:maskerView.bounds];
        coverView.userInteractionEnabled = NO;
        coverView.backgroundColor = [UIColor lightGrayColor];
        coverView.layer.compositingFilter = @"saturationBlendMode";
        coverView.layer.zPosition = FLT_MAX;
        [maskerView addSubview:coverView];
        
        [self.allCoverViews addObject:coverView];
    } else {
        // iOS13 之前系统不支持
    }
}

@end

@implementation IMYAppGrayStyle

+ (void)open {
    NSAssert(NSThread.isMainThread, @"必须在主线程调用!");
    NSMutableSet *windows = [NSMutableSet set];
    [windows addObjectsFromArray:UIApplication.sharedApplication.windows];
    if (@available(iOS 13, *)) {
        for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) {
                continue;
            }
            [windows addObjectsFromArray:scene.windows];
        }
    }
    // 遍历所有window，给它们加上蒙版
    for (UIWindow *window in windows) {
        NSString *className = NSStringFromClass(window.class);
        if (![className containsString:@"UIText"]) {
            if (@available(iOS 13, *)) {
                [IMYAppGrayStyleCoverView showInMaskerView:window];
            } else {
                [self addToViewBefor13:window];
            }
        }
    }
}

+ (void)close {
    NSAssert(NSThread.isMainThread, @"必须在主线程调用!");
    if (@available(iOS 13, *)) {
        for (UIView *coverView in IMYAppGrayStyleCoverView.allCoverViews) {
            [coverView removeFromSuperview];
        }
    } else {
        [self closeBefor13];
    }
}

+ (void)addToView:(UIView *)view {
    if (@available(iOS 13, *)) {
        [IMYAppGrayStyleCoverView showInMaskerView:view];
    } else {
        [self addToViewBefor13:view];
    }
}

+ (void)removeFromView:(UIView *)view {
    if (@available(iOS 13, *)) {
        for (UIView *subview in view.subviews) {
            if ([subview isKindOfClass:IMYAppGrayStyleCoverView.class]) {
                [subview removeFromSuperview];
            }
        }
    } else {
        [self removeFromViewBefor13:view];
    }
}

+ (void)addToViewBefor13:(UIView *)view {
    // 获取RGBA颜色数值
    CGFloat r, g, b, a;
    // lightGrayColor为导致白色背景也变灰，和iOS13以上的效果不一样，所以改成白色
    //    [[UIColor lightGrayColor] getRed:&r green:&g blue:&b alpha:&a];
    [[UIColor whiteColor] getRed:&r green:&g blue:&b alpha:&a];
    // 创建滤镜，使用base64编码，隐藏CAFilter
    id cls = NSClassFromString([self base64DecodeString:@"Q0FGaWx0ZXI="]);
    id filter = [cls filterWithName:@"colorMonochrome"];
    // 设置滤镜参数
    [filter setValue:@[@(r), @(g), @(b), @(a)] forKey:@"inputColor"];
    [filter setValue:@(0) forKey:@"inputBias"];
    [filter setValue:@(1) forKey:@"inputAmount"];
    view.layer.filters = @[filter];
}

+ (void)removeFromViewBefor13:(UIView *)view {
    view.layer.filters = nil;
}

+ (void)closeBefor13 {
    NSMutableSet *windows = [NSMutableSet set];
    [windows addObjectsFromArray:UIApplication.sharedApplication.windows];
    if (@available(iOS 13, *)) {
        for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) {
                continue;
            }
            [windows addObjectsFromArray:scene.windows];
        }
    }
    // 遍历所有window，给它们加上蒙版
    for (UIWindow *window in windows) {
        NSString *className = NSStringFromClass(window.class);
        if (![className containsString:@"UIText"]) {
            [self removeFromViewBefor13:window];
        }
    }
}

+ (NSString *)base64DecodeString:(NSString *)string {
    // 注意：该字符串是base64编码后的字符串
    // 1、转换为二进制数据（完成了解码的过程）
    NSData *data = [[NSData alloc]initWithBase64EncodedString:string options:0];
    // 2、把二进制数据转换成字符串
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end
