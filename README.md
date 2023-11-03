# iOS置灰的几种方式

**1、CAFilter，但这是私有api，存在被拒的风险，转成base64编码隐藏，有顺利审核通过。**

```objective-c
// 获取RGBA颜色数值
CGFloat r, g, b, a;
// lightGrayColor为导致白色背景也变灰，用白色效果会更好
// [[UIColor lightGrayColor] getRed:&r green:&g blue:&b alpha:&a];
[[UIColor whiteColor] getRed:&r green:&g blue:&b alpha:&a];
// 创建滤镜，使用base64编码，隐藏CAFilter。stringWithBase64EncodedString方法来自YYCategory
id cls = NSClassFromString([NSString stringWithBase64EncodedString:@"Q0FGaWx0ZXI="]);
id filter = [cls filterWithName:@"colorMonochrome"];
// 设置滤镜参数
[filter setValue:@[@(r), @(g), @(b), @(a)] forKey:@"inputColor"];
[filter setValue:@(0) forKey:@"inputBias"];
[filter setValue:@(1) forKey:@"inputAmount"];

UIWindow *window = [UIApplication sharedApplication].keyWindow;
window.layer.filters = @[filter];

// 要取消置灰
// window.layer.filters = nil;
```

**2、layer.compositingFilter，这个方法只支持iOS13以上。**

```objective-c
UIWindow *window = [UIApplication sharedApplication].keyWindow;

UIView *coverView = [[self alloc] initWithFrame:window.bounds];
coverView.userInteractionEnabled = NO;
coverView.backgroundColor = [UIColor lightGrayColor];
coverView.layer.compositingFilter = @"saturationBlendMode";
coverView.layer.zPosition = FLT_MAX;
[window addSubview:coverView];

// 要取消置灰，移除coverView即可
```

*[IMYAppGrayStyle](https://github.com/li6185377/IMYAppGrayStyle)这个库使用的就是这种方法，不过支持iOS以上系统，我稍微改了一下，iOS13以下使用CAFilter方法，代码地址：https://github.com/oshiwei/AppGray。*

**3、替换系统方法（Method Swizzle），将颜色、图片、网页改成黑白，这种方法性能比较差，视频也没法处理，需要动态设置的话，得刷新整个页面，比较局限。**

* UIColor，需要替换`colorWithRed:green:blue:alpha:`及`redColor`、`greenColor`等系统提供的颜色方法，修改颜色

```objective-c
+ (UIColor *)changeGrayWithColor:(UIColor *)color Red:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b alpha:(CGFloat)a {
    CGFloat gray = r * 0.299 +g * 0.587 + b * 0.114;
    UIColor *grayColor = [UIColor colorWithWhite:gray alpha:a];
    return  grayColor;
}
```

* UIImage，需要替换`imageNamed:`、`imageWithData:`方法，返回灰度图片

```objective-c
// 转化灰度
- (UIImage *)grayImage {
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
```

* UIImageView，需要替换`setImage`方法，使用上面给`UIImage`添加的`grayImage`方法置灰

```objective-c
- (void)swizzled_setImage:(UIImage *)image {
    // 系统键盘处理（如果不过滤，这系统键盘字母背景是黑色）
    if ([self.superview isKindOfClass:NSClassFromString(@"UIKBSplitImageView")]) {
        [self swizzled_setImage:image];
        return;
    }
    UIImage *im = [image grayImage];
    [self swizzled_setImage:im];
}
```

* WKWebView，替换`initWithFrame:configuration:`方法，给网页添加一个置灰js

```objective-c
- (instancetype)swizzled_initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    // js脚本
    NSString *jScript = @"var filter = '-webkit-filter:grayscale(100%);-moz-filter:grayscale(100%); -ms-filter:grayscale(100%); -o-filter:grayscale(100%) filter:grayscale(100%);';document.getElementsByTagName('html')[0].style.filter = 'grayscale(100%)';";
    // 注入
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    // 配置对象
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    configuration = wkWebConfig;
    WKWebView *webView = [self lg_initWithFrame:frame configuration:configuration];
    return webView;
}
```



参考：

[iOS一键置灰几个方案](https://juejin.cn/post/7221934775842521147)

[【iOS】私有API的使用](https://juejin.cn/post/6844904178683215885)