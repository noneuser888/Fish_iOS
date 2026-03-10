//
//  DateIntervalSelectorView.m
//

#import "DateIntervalSelectorView.h"
#import "DateIntervalSelectorPicker.h"

static CGFloat whiteViewHeight = 400.f;
static CGFloat pickerHeight = 250.f;

//时间回调
typedef void (^ DateBlock)(NSDate *, NSDate *);

@interface DateIntervalSelectorView ()<DateIntervalSelectorPickerDelegate>
{
    CGFloat height;
    CGFloat width;
}

//白色背景
@property (nonatomic, strong) UIView *whiteView;

@property (nonatomic, copy) DateBlock dateBlock;

//开始时间
@property (nonatomic, strong) UIButton *bStart;
//结束时间
@property (nonatomic, strong) UIButton *bEnd;

//开始时间date
@property (nonatomic, strong) NSDate *startDate;
//结束时间date
@property (nonatomic, strong) NSDate *endDate;

//选择器
@property (nonatomic, strong) DateIntervalSelectorPicker *selectorPicker;

//区分当前操作时间——开始时间或结束时间
@property (nonatomic) BOOL timeType;

@end


@implementation DateIntervalSelectorView

+(DateIntervalSelectorView *)shared{
    
    static DateIntervalSelectorView *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [shared createUI];
    });
    return shared;
    
}

-(void)datePickerCompleteBlock:(void (^)(NSDate *startDate, NSDate *endDate))completeBlock{
    
    _dateBlock = completeBlock;
    [self show];
    
}

#pragma mark - 创建布局
-(void)createUI{
    
    height = [UIScreen mainScreen].bounds.size.height;
    width = [UIScreen mainScreen].bounds.size.width;
    
    //默认时间
    self.endDate = [NSDate date];
    self.startDate = [NSDate date];
    
//    //取消手势
//    UITapGestureRecognizer *cancelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCancelAction)];
//    [self addGestureRecognizer:cancelTap];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
    //白色背景
    self.whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, height, width, whiteViewHeight)];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.whiteView];
    
    //完成
    UIButton *bConfirm = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, 40)];
    [bConfirm setTitle:@"完成" forState:0];
    [bConfirm setTitleColor:[UIColor colorWithRed: 79.0/255.0 green:135.0/255.0 blue: 251.0/255.0 alpha:1.0] forState:0];
    [bConfirm addTarget:self action:@selector(buttonConfirm) forControlEvents:UIControlEventTouchUpInside];
    [self.whiteView addSubview:bConfirm];
    
    CGFloat edge = 20.f;
    CGFloat labelWidth = (width - edge * 5) / 2;
    
    //开始时间
    _bStart = [[UIButton alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(bConfirm.frame) + edge * 2, labelWidth, 40)];
    [_bStart setTitle:[self dateFormatWithDate:[NSDate date]] forState:0];
    [_bStart setTitleColor:[UIColor colorWithRed: 79.0/255.0 green:135.0/255.0 blue: 251.0/255.0 alpha:1.0] forState:0];
    _bStart.tag = 1000;
    [_bStart addTarget:self action:@selector(buttonTypeTimeSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.whiteView addSubview:_bStart];
    UIImageView *ivLineStart = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_bStart.frame), CGRectGetMaxY(_bStart.frame), CGRectGetWidth(_bStart.frame), 1)];
    ivLineStart.backgroundColor = [UIColor lightGrayColor];
    [self.whiteView addSubview:ivLineStart];
    
    //至
    UILabel *lFromTo = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_bStart.frame) + edge, CGRectGetMinY(_bStart.frame), edge, CGRectGetHeight(_bStart.frame))];
    lFromTo.text = @"至";
    lFromTo.textColor = [UIColor blackColor];
    lFromTo.textAlignment = NSTextAlignmentCenter;
    lFromTo.font = [UIFont systemFontOfSize:16];
    [self.whiteView addSubview:lFromTo];
    
    //结束时间
    _bEnd = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lFromTo.frame) + edge, CGRectGetMinY(_bStart.frame), CGRectGetWidth(_bStart.frame), CGRectGetHeight(_bStart.frame))];
    [_bEnd setTitle:[self dateFormatWithDate:[NSDate date]] forState:0];
    [_bEnd setTitleColor:[UIColor lightGrayColor] forState:0];
    _bEnd.tag = 1001;
    [_bEnd addTarget:self action:@selector(buttonTypeTimeSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.whiteView addSubview:_bEnd];
    UIImageView *ivLineEnd = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_bEnd.frame), CGRectGetMaxY(_bEnd.frame), CGRectGetWidth(ivLineStart.frame), CGRectGetHeight(ivLineStart.frame))];
    ivLineEnd.backgroundColor = [UIColor lightGrayColor];
    [self.whiteView addSubview:ivLineEnd];
    
    //选择器
    self.selectorPicker = [[DateIntervalSelectorPicker alloc]initWithDatePickerView];
    self.selectorPicker.frame = CGRectMake(0, whiteViewHeight - pickerHeight, width, pickerHeight);
    self.selectorPicker.pvDelegate = self;
    [self.whiteView addSubview:self.selectorPicker];
    
}

-(void)buttonTypeTimeSelect:(UIButton *)sender{
    
    if (sender.tag - 1000 == 0) {
        [_bStart setTitleColor: [UIColor colorWithRed: 79.0/255.0 green:135.0/255.0 blue: 251.0/255.0 alpha:1.0] forState:0];
        [_bEnd setTitleColor:[UIColor lightGrayColor] forState:0];
        self.timeType = NO;
    }else{
        [_bStart setTitleColor:[UIColor lightGrayColor] forState:0];
        [_bEnd setTitleColor:[UIColor colorWithRed: 79.0/255.0 green:135.0/255.0 blue: 251.0/255.0 alpha:1.0] forState:0];
        self.timeType = YES;
    }
    
}

-(void)dateWithSelect:(NSDate *)date{
    
    //时间转时间戳
    NSString *time = [self dateFormatWithDate:date];
    
    //选择结束时间
    if (self.timeType) {
        self.endDate = date;
        [_bEnd setTitle:time forState:0];
    }
    
    //选择开始时间
    else{
        self.startDate = date;
        [_bStart setTitle:time forState:0];
    }
    
}

-(void)buttonConfirm{
    
    //开始时间的时间戳
    NSInteger sDate = [self timestampWithDate:self.startDate];
    //结束时间的时间戳
    NSInteger eDate = [self timestampWithDate:self.endDate];
    
    //开始时间的时间戳大于结束时间的时间戳是不对的，直接return，提示时间不对
    if (sDate > eDate) {
        [SVProgressHUD showErrorWithStatus:@"时间选择错误"];
        return;
    }
    
    if (_dateBlock) {
        _dateBlock(self.startDate,self.endDate);
    }
    [self cancelAction];
    
}

//显示手势
-(void)show{
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [UIView animateWithDuration:0.25 animations:^{
        self.whiteView.frame = CGRectMake(0, self->height - whiteViewHeight, self->width, whiteViewHeight);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    }];
    
}

//取消手势
-(void)cancelAction{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.whiteView.frame = CGRectMake(0, self->height, self->width, whiteViewHeight);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

//时间格式
-(NSString *)dateFormatWithDate:(NSDate *)date{
    
    NSString *formatStr = @"yyyy-MM-dd";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatStr];
    return [dateFormatter stringFromDate:date];
    
}

//时间转时间戳
-(NSInteger)timestampWithDate:(NSDate *)date{
    return [date timeIntervalSince1970] / 1000;
}

@end
