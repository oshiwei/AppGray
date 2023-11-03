//
//  WKWebView+Gray.m


#import "WKWebView+Gray.h"


@implementation WKWebView (Gray)

+ (void)setAppGray {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod([self class], @selector(initWithFrame:configuration:));
        Method swizzledMethod = class_getInstanceMethod([self class], @selector(swizzled_initWithFrame:configuration:));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

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
    WKWebView *webView = [self swizzled_initWithFrame:frame configuration:configuration];
    return webView;
}


@end
