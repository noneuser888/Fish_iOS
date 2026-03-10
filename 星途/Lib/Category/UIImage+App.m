//
//  UIImage+App.m
//  星途
//
//  Created by  on 2020/3/14.
//  
//

#import "UIImage+App.h"


@implementation UIImage (App)

+ (UIImage *)imageWithColor:(UIColor *)color {

    //创建1像素区域并开始图片绘图
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    
    //创建画板并填充颜色和区域
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    //从画板上获取图片并关闭图片绘图
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)convertViewToImage:(UIView *)view{
  CGSize s = view.bounds.size;
  // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需  要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
  UIGraphicsBeginImageContextWithOptions(s, YES, [UIScreen mainScreen].scale);
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

-(UIImage*)scaleToSize:(CGSize)size
{
    size = CGSizeMake(size.width  , size.height );
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width , size.height )];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *imgData = [[NSData alloc] initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:imgData];
}

- (NSString*)encodeToBase64String {
    return [UIImagePNGRepresentation(self) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

@end
