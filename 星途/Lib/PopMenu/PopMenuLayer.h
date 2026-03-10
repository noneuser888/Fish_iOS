//
//  PopMenuLayer.h
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ArrowDirection) {
    ArrowDirectionRight = 0,
    ArrowDirectionBottom,
    ArrowDirectionLeft,
    ArrowDirectionTop,
};

NS_ASSUME_NONNULL_BEGIN

@interface PopMenuLayer : NSObject

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat arrowRadius;
@property (nonatomic, assign) CGFloat arrowHeight;
@property (nonatomic, assign) CGFloat arrowWidth;
@property (nonatomic, assign) ArrowDirection arrowDirection;
@property (nonatomic, assign) CGFloat arrowPosition;
@property (nonatomic, assign) CGSize size;

- (instancetype)initWithSize:(CGSize)size;
- (CAShapeLayer *)layer;

@end

NS_ASSUME_NONNULL_END
