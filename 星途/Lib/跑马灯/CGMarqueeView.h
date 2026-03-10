//
//  CGMarqueeView.h
//  星途
//
//  Created by  on 2020/3/23.
//  
//

#import <UIKit/UIKit.h>


@interface CGMarqueeView : UIView

/// 字符串之间的间隙
@property (nonatomic, assign) CGFloat minimumLineSpacing;
/// 用于控制首尾连接的文字之间的间距，默认为 40pt。
//@property (nonatomic, assign) CGFloat spacingBetweenHeadToTail;
/// 控制滚动的速度，1 表示一帧滚动 1pt，10 表示一帧滚动 10pt，默认为 .5，与系统一致。
@property (nonatomic, assign) CGFloat speed;
/// 字体颜色
@property (nonatomic, strong) UIColor *textColor;

- (void)setData:(NSArray *)data;

- (void)startAnimation;

- (void)stopAnimation;

@end

