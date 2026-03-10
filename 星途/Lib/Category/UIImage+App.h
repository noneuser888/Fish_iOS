//
//  UIImage+App.h
//  星途
//
//  Created by  on 2020/3/14.
//  
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (App)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)convertViewToImage:(UIView *)view;

-(UIImage *)scaleToSize:(CGSize)size;

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData;

- (NSString *)encodeToBase64String;
@end

NS_ASSUME_NONNULL_END
