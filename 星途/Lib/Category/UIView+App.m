//
//  UIView+App.m
//  星途
//
//  Created by  on 2020/3/13.
//  
//

#import "UIView+App.h"


@implementation UIView (App)

@dynamic app_cornerRadius;
@dynamic app_corderWidth;
@dynamic app_borderColor;


- (CGFloat)app_cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setApp_cornerRadius:(CGFloat)app_cornerRadius {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = app_cornerRadius;
}

- (CGFloat)app_corderWidth {
    return self.layer.borderWidth;
}

- (void)setApp_corderWidth:(CGFloat)app_corderWidth {
    self.layer.borderWidth = app_corderWidth;
}

//- (UIColor *)app_borderColor {
//    return self.layer.borderColor;
//}

- (void)setApp_borderColor:(UIColor *)app_borderColor {
    self.layer.borderColor = app_borderColor.CGColor;
}

- (void)setGradientBG:(NSArray *)colors frame:(CGRect)frame {
    CALayer *layer = [self gradientLayer:colors frame:frame];
    [self.layer insertSublayer:layer atIndex:0];
}

- (CALayer *)gradientLayer:(NSArray *)colors frame:(CGRect)frame {
    NSMutableArray *gradientLocations = [[NSMutableArray alloc] init];
    [gradientLocations addObject:@(0.0)];
    for (int i = 1; i < colors.count - 1; i++) {
        NSNumber *locations = [NSNumber numberWithFloat: 1.0 / ((float)(colors.count-1)) * (float)i];
        [gradientLocations addObject:locations];
    }
    [gradientLocations addObject:@(1.0)];
    NSMutableArray *cgColors = [[NSMutableArray alloc] init];
    for (UIColor *color in colors) {
        [cgColors addObject: (id)color.CGColor];
    }
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = cgColors;
    gradientLayer.locations = gradientLocations;
    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint endPoint = CGPointMake(1, 0);
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    gradientLayer.frame = frame;
    return gradientLayer;
}

@end
