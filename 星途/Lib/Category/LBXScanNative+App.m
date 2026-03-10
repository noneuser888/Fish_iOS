//
//  LBXScanNative+App.m
//

#import "LBXScanNative+App.h"

@implementation LBXScanNative (App)

+ (UIImage*)createQRWithString:(NSString*)text
                        QRSize:(CGSize)size
                          icon:(UIImage *)icon {
    UIImage *qrCodeImg = [LBXScanNative createQRWithString:text QRSize:size];
    CGSize linkSize = CGSizeMake(size.width/4, size.height/4);
    
    CGFloat linkX = (size.width - linkSize.width) / 2;
    CGFloat linkY = (size.height - linkSize.height) / 2;
    CGRect waterImageRect = CGRectMake(linkX, linkY, linkSize.width, linkSize.height);
    
    UIImage *waterImage = [icon scaleToSize:waterImageRect.size];
    
    //1.开启上下文
     UIGraphicsBeginImageContextWithOptions(qrCodeImg.size, NO, 0);
     //2.绘制背景图片
     [qrCodeImg drawInRect:CGRectMake(0, 0, qrCodeImg.size.width, qrCodeImg.size.height)];
     //绘制水印图片到当前上下文
     [waterImage drawInRect:waterImageRect];
     //3.从上下文中获取新图片
     UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
     //4.关闭图形上下文
     UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage*)createQRWithString:(NSString*)text
                        QRSize:(CGSize)size
                       QRColor:(UIColor*)qrColor
                       bkColor:(UIColor*)bkColor
                          icon:(UIImage *)icon {
    
    UIImage *qrCodeImg = [LBXScanNative createQRWithString:text QRSize:size QRColor:qrColor bkColor:bkColor];
    CGSize linkSize = CGSizeMake(size.width/4, size.height/4);
    
    CGFloat linkX = (size.width - linkSize.width) / 2;
    CGFloat linkY = (size.height - linkSize.height) / 2;
    CGRect waterImageRect = CGRectMake(linkX, linkY, linkSize.width, linkSize.height);
    
    UIImage *waterImage = [icon scaleToSize:waterImageRect.size];
    
    //1.开启上下文
     UIGraphicsBeginImageContextWithOptions(qrCodeImg.size, NO, 0);
     //2.绘制背景图片
     [qrCodeImg drawInRect:CGRectMake(0, 0, qrCodeImg.size.width, qrCodeImg.size.height)];
     //绘制水印图片到当前上下文
     [waterImage drawInRect:waterImageRect];
     //3.从上下文中获取新图片
     UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
     //4.关闭图形上下文
     UIGraphicsEndImageContext();
    
    return newImage;
    
}


@end
