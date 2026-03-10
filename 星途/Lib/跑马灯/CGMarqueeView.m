//
//  CGMarqueeView.m
//  星途
//
//  Created by  on 2020/3/23.
//  
//

#import "CGMarqueeView.h"

@interface CGMarqueeCell : UICollectionViewCell

@property (nonatomic, assign) BOOL isLast;

//@property (nonatomic, assign) CGFloat spacingBetweenHeadToTail;

@property (nonatomic, strong) UILabel *textLabel;

- (void)setData:(NSString *)text;

@end

@implementation CGMarqueeCell

- (void)setData:(NSString *)text {
    self.textLabel.text = text;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.spacingBetweenHeadToTail = 40;
        self.isLast = NO;
    }
    return self;
}

- (UILabel *)textLabel {
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor colorWithHexString:@"#1F3F58"];
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:_textLabel];
        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return _textLabel;
    
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    CGSize size = [self.contentView systemLayoutSizeFittingSize:layoutAttributes.size];
    CGRect cellFrame = layoutAttributes.frame;
    cellFrame.size.width = size.width;
//    if (self.isLast) {
//        cellFrame.size.width += _spacingBetweenHeadToTail;
//    }
    layoutAttributes.frame = cellFrame;
    return  layoutAttributes;
}


@end

@interface CGMarqueeView()<UICollectionViewDataSource>

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat maxScrollWidth;

@end

@implementation CGMarqueeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.minimumLineSpacing = 20;
//        self.spacingBetweenHeadToTail = 40;
        self.speed = 0.5;
        self.textColor = [UIColor colorWithHexString:@"#FF9320"];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.minimumLineSpacing = 20;
//        self.spacingBetweenHeadToTail = 40;
        self.speed = 0.5;
        self.textColor = [UIColor colorWithHexString:@"#FF9320"];
    }
    return self;
}

- (void)setData:(NSArray *)data {
    self.dataSource = data;
    CGFloat tmpMaxScrollWidth = 0;
    for (NSString *item in data) {
        tmpMaxScrollWidth += [self calculateStr:item].width;
        tmpMaxScrollWidth += self.minimumLineSpacing;
    }
    if (tmpMaxScrollWidth - self.minimumLineSpacing <= self.bounds.size.width) {
        self.maxScrollWidth = tmpMaxScrollWidth - self.minimumLineSpacing;
    } else {
        self.maxScrollWidth = tmpMaxScrollWidth;
    }
    
    [self.collectionView reloadData];
}

- (void)startAnimation {
    if (self.maxScrollWidth <= self.bounds.size.width) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.displayLink.paused) {
            self.displayLink.paused = NO;
        }
    });
}

- (void)stopAnimation {
    self.displayLink.paused = YES;
    [self.collectionView setContentOffset:CGPointMake(0, 0)];
}


- (void)handleDisplayLink:(CADisplayLink *)displayLink {
    if (self.collectionView.contentOffset.x == 0) {
        self.displayLink.paused = NO;
    }
    CGFloat x = self.collectionView.contentOffset.x;
    x += self.speed;
    [self.collectionView setContentOffset:CGPointMake(x, 0)];
    if (self.collectionView.contentOffset.x >= self.maxScrollWidth) {
        self.displayLink.paused = YES;
        [self.collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self handleDisplayLink: displayLink];
        });
    }
}

- (CGSize)calculateStr:(NSString *)str {
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    NSAttributedString *attriStr = [[NSAttributedString alloc] initWithString:str attributes:attribute];
    return [attriStr boundingRectWithSize:CGSizeMake(100000, self.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
}

- (CADisplayLink *)displayLink {
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
        [_displayLink addToRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
    }
    return _displayLink;
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.estimatedItemSize = self.bounds.size;
        layout.minimumLineSpacing = self.minimumLineSpacing;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = UIColor.clearColor;
        [_collectionView setUserInteractionEnabled:NO];
        [_collectionView registerClass:[CGMarqueeCell class] forCellWithReuseIdentifier:@"CGMarqueeCell"];
        [self addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGMarqueeCell *cell = (CGMarqueeCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CGMarqueeCell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = self.backgroundColor;
    cell.textLabel.textColor = self.textColor;
    [cell setData:self.dataSource[indexPath.item]];
    if (indexPath.item == self.dataSource.count - 1) {
        cell.isLast = YES;
//        cell.spacingBetweenHeadToTail = self.spacingBetweenHeadToTail;
    }
    return cell;
}

- (void)dealloc
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}
@end
