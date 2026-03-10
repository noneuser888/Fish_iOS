//
//  PopMenuView.m
//

#import "PopMenuView.h"
#import "PopMenuLayer.h"
#import "PopMenuCell.h"

#define WX_SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define WX_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@interface PopMenuView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) void (^selectedItemComplete)(NSInteger currentIndex);
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, assign) CGPoint beginPosition;
@property (nonatomic, strong) UIColor *cellColor;
@property (nonatomic, copy, readwrite) NSArray<NSString *> *titles;
@property (nonatomic, copy, readwrite) NSArray<NSString *> *iconImageNames;

@end

@implementation PopMenuView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.tableView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTappedTarget:)];
        [self.backgroundView addGestureRecognizer:tap];
    }
    return self;
}

+ (void)showPopMenuWithIconImageNames:(NSArray<NSString *> *)iconImageNames
                       originPosition:(CGPoint)position
                 selectedItemComplete:(void(^)(NSInteger currentIndex))complete {
    
    [self showPopMenuWithIconImageNames:iconImageNames
                         originPosition:position
                      needSeparatorLine:YES
                   selectedItemComplete:complete];
}

+ (void)showPopMenuWithIconImageNames:(NSArray<NSString *> *)iconImageNames
                       originPosition:(CGPoint)position
                    needSeparatorLine:(BOOL)isNeedSeparatorLine
                 selectedItemComplete:(void(^)(NSInteger currentIndex))complete {
    
    [self showPopMenuWithIconImageNames:iconImageNames
                                 titles:nil
                         originPosition:position
                      needSeparatorLine:isNeedSeparatorLine
                   selectedItemComplete:complete];
}

+ (void)showPopMenuWithTitles:(NSArray<NSString *> *)titles
               originPosition:(CGPoint)position
         selectedItemComplete:(void(^)(NSInteger currentIndex))complete {
    
    [self showPopMenuWithTitles:titles
                 originPosition:position
              needSeparatorLine:YES
           selectedItemComplete:complete];
}

+ (void)showPopMenuWithTitles:(NSArray<NSString *> *)titles
               originPosition:(CGPoint)position
            needSeparatorLine:(BOOL)isNeedSeparatorLine
         selectedItemComplete:(void(^)(NSInteger currentIndex))complete {
    
    [self showPopMenuWithIconImageNames:nil
                                 titles:titles
                         originPosition:position
                      needSeparatorLine:isNeedSeparatorLine
                   selectedItemComplete:complete];
}

+ (void)showPopMenuWithIconImageNames:(NSArray<NSString *> * _Nullable)iconImageNames
                               titles:(NSArray<NSString *> * _Nullable)titles
                       originPosition:(CGPoint)position
                 selectedItemComplete:(void(^)(NSInteger currentIndex))complete {
    
    [self showPopMenuWithIconImageNames:iconImageNames
                                 titles:titles
                         originPosition:position
                      needSeparatorLine:YES
                   selectedItemComplete:complete];
}

+ (void)showPopMenuWithIconImageNames:(NSArray<NSString *> * _Nullable)iconImageNames
                               titles:(NSArray<NSString *> * _Nullable)titles
                       originPosition:(CGPoint)position
                    needSeparatorLine:(BOOL)isNeedSeparatorLine
                 selectedItemComplete:(void(^)(NSInteger currentIndex))complete {
    
    [self showPopMenuWithIconImageNames:iconImageNames
                                 titles:titles
                         originPosition:position
                           heightOfItem:0
                            widthOfView:0
                  backgroundColorOfView:[UIColor whiteColor]
                      needSeparatorLine:isNeedSeparatorLine
                   selectedItemComplete:complete];
}

+ (void)showPopMenuWithIconImageNames:(NSArray<NSString *> * _Nullable)iconImageNames
                               titles:(NSArray<NSString *> * _Nullable)titles
                       originPosition:(CGPoint)position
                         heightOfItem:(CGFloat)height
                          widthOfView:(CGFloat)width
                backgroundColorOfView:(UIColor *)color
                    needSeparatorLine:(BOOL)isNeedSeparatorLine
                 selectedItemComplete:(void(^)(NSInteger currentIndex))complete {
    
    [self showPopMenuWithIconImageNames:iconImageNames
                                 titles:titles
                         originPosition:position
                           heightOfItem:height
                            widthOfView:width
                  backgroundColorOfView:color
                       titleLabelOfItem:nil
                      needSeparatorLine:isNeedSeparatorLine
                   selectedItemComplete:complete];
}

+ (void)showPopMenuWithIconImageNames:(NSArray<NSString *> * _Nullable)iconImageNames
                               titles:(NSArray<NSString *> * _Nullable)titles
                       originPosition:(CGPoint)position
                         heightOfItem:(CGFloat)height
                          widthOfView:(CGFloat)width
                backgroundColorOfView:(UIColor *)color
                     titleLabelOfItem:(UILabel * _Nullable)titleLabel
                    needSeparatorLine:(BOOL)isNeedSeparatorLine
                 selectedItemComplete:(void(^)(NSInteger currentIndex))complete {
    
    PopMenuView *v                = [[PopMenuView alloc] init];
    v.iconImageNames            = iconImageNames;
    v.titles                    = titles;
    v.beginPosition             = position;
    v.itemHeight                = height == 0 ? 45 : height;
    v.viewWidth                 = width == 0 ? [[UIScreen mainScreen] bounds].size.width / 2 : width;
    v.tableView.backgroundColor = color;
    v.cellColor                 = color;
    v.titleLabel                = titleLabel;
    v.selectedItemComplete      = complete;
    v.tableView.rowHeight       = v.itemHeight;
    if (isNeedSeparatorLine) {
        v.tableView.separatorStyle  = UITableViewCellSeparatorStyleSingleLine;
    } else {
        v.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    }
    [v.tableView reloadData];
    [v showView];
}

- (void)backgroundTappedTarget:(id)sender {
    [self hidenView];
}

- (void)showView {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.backgroundView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    [self setupViewAndArrowShape];
    [self showAnimation];
}

- (void)setupViewAndArrowShape {
    CGRect toFrame = CGRectZero;
    toFrame.size.width = self.viewWidth;
    if (self.iconImageNames.count == 0 || self.iconImageNames == nil) {
        toFrame.size.height = self.itemHeight * self.titles.count + 15;
    } else if (self.titles == nil || self.titles.count == 0) {
        toFrame.size.height = self.itemHeight * self.iconImageNames.count + 15;
    } else {
        toFrame.size.height = self.itemHeight * self.titles.count + 15;
    }
    
    PopMenuLayer *bbLayer = [[PopMenuLayer alloc] initWithSize:toFrame.size];
    
    if (self.beginPosition.x + self.viewWidth / 2 > WX_SCREEN_WIDTH) {
        toFrame.origin.x = WX_SCREEN_WIDTH - 10 - self.viewWidth;
        bbLayer.arrowDirection = ArrowDirectionTop;
        bbLayer.arrowPosition = (self.beginPosition.x - toFrame.origin.x + 15) / self.viewWidth;
        self.layer.anchorPoint = CGPointMake(bbLayer.arrowPosition, 0);
    } else if (self.beginPosition.x - self.viewWidth / 2 < 0){
        toFrame.origin.x = 10;
        bbLayer.arrowDirection = ArrowDirectionTop;
        bbLayer.arrowPosition = (self.beginPosition.x - toFrame.origin.x - 15) / self.viewWidth;
        self.layer.anchorPoint = CGPointMake(bbLayer.arrowPosition, 0);
    } else {
        toFrame.origin.x = self.beginPosition.x - self.viewWidth / 2;
        bbLayer.arrowDirection = ArrowDirectionTop;
        bbLayer.arrowPosition = (self.beginPosition.x - toFrame.origin.x) / self.viewWidth;
        self.layer.anchorPoint = CGPointMake(bbLayer.arrowPosition, 0);
    }
    
    if (self.beginPosition.y + toFrame.size.height > WX_SCREEN_HEIGHT) {
        toFrame.origin.y = self.beginPosition.y - toFrame.size.height - 15;
        bbLayer.arrowDirection = ArrowDirectionBottom;
        self.layer.anchorPoint = CGPointMake(bbLayer.arrowPosition, 1);
    } else {
        toFrame.origin.y = self.beginPosition.y + 15;
    }
    
    self.tableView.frame = CGRectZero;
    self.frame = CGRectMake(self.beginPosition.x, self.beginPosition.y, 0, 0);
    self.alpha = 0;
    self.frame = toFrame;
    if (self.beginPosition.y + toFrame.size.height > WX_SCREEN_HEIGHT) {
        self.tableView.contentInset = UIEdgeInsetsZero;
    } else {
        self.tableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    }
    self.tableView.frame = CGRectMake(0, 0, toFrame.size.width, toFrame.size.height);
    
    bbLayer.cornerRadius = 8;
    bbLayer.arrowHeight = 15;
    bbLayer.arrowWidth = 30;
    bbLayer.arrowRadius = 0;
    [self.layer setMask:[bbLayer layer]];
}

- (void)showAnimation {
    self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:0.35 animations:^{
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        self.alpha = 1;
        self.layer.affineTransform = CGAffineTransformIdentity;
    }];
}

- (void)hidenView {
    [UIView animateWithDuration:0.35 animations:^{
        self.alpha = 0;
        self.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.layer.affineTransform = CGAffineTransformIdentity;
        [self.backgroundView removeFromSuperview];
    }];
}

#pragma mark - UITableView DataSource Method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.titles.count > 0) {
        return self.titles.count;
    }
    
    if (self.iconImageNames.count > 0){
        return self.iconImageNames.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PopMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PopMenuCell"];
    if (!cell) {
        cell = [[PopMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PopMenuCell"];
    }
    
    if (self.iconImageNames.count == 0 || self.iconImageNames == nil) {
        cell.showType = PopMenuTypeOnlyTitle;
        cell.titleLabel.text = self.titles[indexPath.row];
        
    } else if (self.titles == nil || self.titles.count == 0) {
        cell.showType = PopMenuTypeOnlyIcon;
        cell.iconImageView.image = [UIImage imageNamed:self.iconImageNames[indexPath.row]];
    } else {
        cell.showType = PopMenuTypeNormal;
        cell.iconImageView.image = [UIImage imageNamed:self.iconImageNames[indexPath.row]];
        cell.titleLabel.text = self.titles[indexPath.row];
    }
    if (self.titleLabel) {
        cell.titleLabel.textColor = self.titleLabel.textColor;
        cell.titleLabel.textAlignment = self.titleLabel.textAlignment;
        cell.titleLabel.font = self.titleLabel.font;
    }
    
    cell.contentView.backgroundColor = self.cellColor;
    
    if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        cell.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, 0);
    } else {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return cell;
}

#pragma mark - UITableView Delegate Method
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self hidenView];
    self.selectedItemComplete(indexPath.row);
}

#pragma mark - Setter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView                 = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.dataSource      = self;
        _tableView.delegate        = self;
        _tableView.scrollEnabled   = NO;
    }
    return _tableView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    return _backgroundView;
}

@end
