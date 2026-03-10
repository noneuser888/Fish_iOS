//
//  PopMenuLayer.m
//

#import "PopMenuLayer.h"

#define CORNER_RADIUS   8   // 默认矩形框圆角半径
#define ARROW_WIDTH     30  // 默认箭头宽带
#define ARROW_HEIGHT    12  // 默认箭头高度
#define ARROW_DIRECTION 1   // 默认箭头方向，向下
#define ARROW_POSITION  0.5 // 默认箭头相对位置，居中
#define ARROW_RADIUS    3   // 默认箭头指向处的圆角半径

@interface PopMenuLayer()

@end

@implementation PopMenuLayer

#pragma mark - preparation
- (NSMutableArray *)keyPoints {
    NSMutableArray *points = [NSMutableArray array];
    CGPoint beginPoint;
    CGPoint topPoint;
    CGPoint endPoint;
    CGFloat validWidthForTopPoint = _size.width - 2 * _cornerRadius - _arrowWidth;
    CGFloat validHeightForTopPoint = _size.height - 2 * _cornerRadius - _arrowWidth;
    CGFloat x = 0, y = 0;
    CGFloat width = _size.width, height = _size.height;
    
    switch (_arrowDirection)
    {
        case ArrowDirectionRight:
        {
            width -= _arrowHeight;
            topPoint = CGPointMake(_size.width , _size.height / 2 + validHeightForTopPoint*(_arrowPosition - 0.5));
            beginPoint = CGPointMake(topPoint.x - _arrowHeight, topPoint.y - _arrowWidth/2);
            endPoint = CGPointMake(beginPoint.x, beginPoint.y + _arrowWidth);
        }
            break;
        case ArrowDirectionBottom:
        {
            height -= _arrowHeight;
            
            topPoint = CGPointMake(_size.width / 2 + validWidthForTopPoint*(_arrowPosition - 0.5), _size.height);
            beginPoint = CGPointMake(topPoint.x + _arrowWidth/2, topPoint.y - _arrowHeight);
            endPoint = CGPointMake(beginPoint.x - _arrowWidth, beginPoint.y);
        }
            break;
        case ArrowDirectionLeft:
        {
            x = _arrowHeight;
            width -= _arrowHeight;
            
            topPoint = CGPointMake(0, _size.height / 2 + validHeightForTopPoint*(_arrowPosition - 0.5));
            beginPoint = CGPointMake(topPoint.x + _arrowHeight, topPoint.y + _arrowWidth/2);
            endPoint = CGPointMake(beginPoint.x, beginPoint.y - _arrowWidth);
        }
            break;
        case ArrowDirectionTop:
        {
            y = _arrowHeight;
            height -= _arrowHeight;
            
            topPoint = CGPointMake(_size.width / 2 + validWidthForTopPoint*(_arrowPosition - 0.5), 0);
            beginPoint = CGPointMake(topPoint.x - _arrowWidth/2, topPoint.y + _arrowHeight);
            endPoint = CGPointMake(beginPoint.x + _arrowWidth, beginPoint.y);
        }
            break;
    }
    
    points = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:beginPoint],
              [NSValue valueWithCGPoint:topPoint],
              [NSValue valueWithCGPoint:endPoint],
              nil];
    CGPoint bottomRight = CGPointMake(x + width, y + height);
    CGPoint bottomLeft = CGPointMake(x, y + height);
    CGPoint topLeft = CGPointMake(x, y);
    CGPoint topRight = CGPointMake(x + width, y);
    NSMutableArray *rectPoints = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint:bottomRight],
                                  [NSValue valueWithCGPoint:bottomLeft],
                                  [NSValue valueWithCGPoint:topLeft],
                                  [NSValue valueWithCGPoint:topRight],
                                  nil];
    int rectPointIndex = (int)_arrowDirection;
    for(int i = 0; i < 4; ++i) {
        [points addObject:[rectPoints objectAtIndex:rectPointIndex]];
        rectPointIndex = (rectPointIndex + 1) % 4;
    }
    return points;
}

#pragma mark - Draw bubblePath
- (CGPathRef)bubblePath {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    NSMutableArray *points = [self keyPoints];
    CGPoint currentPoint = [[points objectAtIndex:6] CGPointValue];
    CGContextMoveToPoint(ctx, currentPoint.x, currentPoint.y);
    CGPoint pointA, pointB;
    CGFloat radius;
    int i = 0;
    while(1) {
        if (i > 6)
            break;
        radius = i < 3 ?  _arrowRadius : _cornerRadius;
        pointA = [[points objectAtIndex:i] CGPointValue];
        pointB = [[points objectAtIndex:(i + 1) % 7] CGPointValue];
        CGContextAddArcToPoint(ctx, pointA.x, pointA.y, pointB.x, pointB.y, radius);
        i = i + 1;
    }
    CGContextClosePath(ctx);
    CGPathRef path = CGContextCopyPath(ctx);
    CGContextRelease(ctx);
    return path;
}

- (CAShapeLayer *)layer{
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = [self bubblePath];
    return layer;
}

#pragma mark - Setup
- (void)setDefaultProperty {
    _cornerRadius   = CORNER_RADIUS;
    _arrowWidth     = ARROW_WIDTH;
    _arrowHeight    = ARROW_HEIGHT;
    _arrowDirection = ARROW_DIRECTION;
    _arrowPosition  = ARROW_POSITION;
    _arrowRadius    = ARROW_RADIUS;
}

#pragma mark - Init
- (instancetype)initWithSize:(CGSize)size {
    if(self = [super init]) {
        [self setDefaultProperty];
        _size = size;
    }
    return self;
}
@end
