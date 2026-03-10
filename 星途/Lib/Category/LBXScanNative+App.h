//
//  LBXScanNative+App.h
//

#import "LBXScanNative.h"

NS_ASSUME_NONNULL_BEGIN

@interface LBXScanNative (App)

/**
 生成QR二维码

 @param text 字符串
 @param size 大小
 @param icon 二维码中心图片
 @return 二维码图像
 */
+ (UIImage*)createQRWithString:(NSString*)text
                        QRSize:(CGSize)size
                          icon:(UIImage *)icon;

/**
 生成QR二维码

 @param text 字符串
 @param size 大小
 @param qrColor 二维码前景色
 @param bkColor 二维码背景色
 @param icon 二维码中心图片
 @return 二维码图像
 */
+ (UIImage*)createQRWithString:(NSString*)text
                        QRSize:(CGSize)size
                       QRColor:(UIColor*)qrColor
                       bkColor:(UIColor*)bkColor
                          icon:(UIImage *)icon;

@end

NS_ASSUME_NONNULL_END
