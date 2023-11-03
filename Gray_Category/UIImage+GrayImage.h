//
//  UIWebView+Gray.h
//
//
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (GrayImage)

+ (void)setAppGray;

//转化灰度
- (UIImage *)grayImage;

@end

NS_ASSUME_NONNULL_END
