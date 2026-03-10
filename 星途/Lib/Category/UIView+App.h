//
//  UIView+App.h
//  星途
//
//  Created by  on 2020/3/13.
//  
//


#import <UIKit/UIKit.h>


@interface UIView (App)

@property (nonatomic) IBInspectable CGFloat app_cornerRadius;
@property (nonatomic) IBInspectable CGFloat app_corderWidth;
@property (nonatomic) IBInspectable UIColor *app_borderColor;

- (void)setGradientBG:(NSArray *)colors frame:(CGRect)frame;

@end

