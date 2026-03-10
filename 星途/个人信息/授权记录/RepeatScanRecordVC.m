//
//  RepeatScanRecordVC.m
//  星途
//
//  Created by  on 2020/4/21.
//  
//

#import "RepeatScanRecordVC.h"
#import "AuthRecordCell.h"
#import "DateIntervalSelectorPicker.h"
#import "DateIntervalSelectorView.h"
#import "ScanQRVC.h"

@interface RepeatScanRecordVC ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSMutableArray *currentRepeatRecord;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSString *endDate;

@end

@implementation RepeatScanRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"授权记录";
    self.page = 1;
    self.currentRepeatRecord = [[NSMutableArray alloc] init];
    self.tableView = [[UITableView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#F8F8F8"];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[AuthRecordCell xx_nib] forCellReuseIdentifier:@"AuthRecordCell"];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 80.f;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    @weakify(self)
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        //下拉刷新
        self.page = 1;
        [self requestData];
    }];
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.page += 1;
        [self requestData];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"筛选" style:UIBarButtonItemStylePlain target:self action:@selector(datePicker)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.tableView addGestureRecognizer:longPressGR];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPressGR
{
    if (longPressGR.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [longPressGR locationInView:_tableView];
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
        NSDictionary *model = self.dataSource[indexPath.row];
        [self showInputAlert:model index:indexPath.row];
    }
}

- (void)datePicker {
    @weakify(self);
    [[DateIntervalSelectorView shared] datePickerCompleteBlock:^(NSDate * _Nonnull startDate, NSDate * _Nonnull endDate) {
        @strongify(self);
        self.startDate = [NSString stringWithFormat:@"%.lf", ([startDate timeIntervalSince1970])*1000];
        self.endDate = [NSString stringWithFormat:@"%.lf", ([endDate timeIntervalSince1970])*1000];
        [self requestData];
    }];
}


- (void)setData:(NSDictionary *)data {
    NSArray *dataArr = data[@"list"][@"records"];
    if (self.page <= 1) {
        self.dataSource = dataArr;
        [self.tableView.mj_header endRefreshing];
        if (dataArr.count < 20) {
            self.tableView.mj_footer = nil;
        } else {
            [self.tableView.mj_footer endRefreshing];
        }
    } else {
        NSMutableArray *tmpData = [[NSMutableArray alloc] initWithArray:self.dataSource];
        [tmpData addObjectsFromArray:dataArr];
        self.dataSource = tmpData;
        if (dataArr.count < 20) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer endRefreshing];
        }
    }
    [self.tableView reloadData];
}

- (NSDictionary *)localSearchWithId:(NSString *)id {
    NSDictionary *tempModel;
    for (NSDictionary *model in self.dataSource) {
        NSString *tempAppId = model[@"id"];
        if ([id isEqualToString:tempAppId]) {
            tempModel = model;
        }
    }
    return tempModel;
}

- (void)requestData {
    if (!self.appId) {
        return;
    }
    NSDictionary *parameters;
    if (self.startDate && ![self.startDate isEqualToString:@""] && self.endDate && ![self.endDate isEqualToString:@""]) {
        parameters = @{
            @"appId": self.appId,
            @"taskType":@(1),
            @"startTime": self.startDate,
            @"endTime":self.endDate
        };
    } else {
        parameters = @{
            @"appId": self.appId,
            @"taskType":@(1)
        };
    }
    NSString *url = [NSString stringWithFormat:@"%@/authRecord/%ld/20", baseUrl,(long)self.page];
    @weakify(self);
    [[NetworkingManager manager]
     postDataWithUrl:url
     parameters:parameters success:^(id json) {
        @strongify(self);
        [self setData:(NSDictionary *)json[@"data"]];
    } failure:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

+ (NSDictionary *)currentAuthRecord {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"RepeatScanRecordVC.AuthRecord"]) {
        NSDictionary *currentRecord = [[NSUserDefaults standardUserDefaults] valueForKey:@"RepeatScanRecordVC.AuthRecord"];
        return currentRecord;
    }
    return nil;
}

#pragma mark UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AuthRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AuthRecordCell" forIndexPath:indexPath];
    NSDictionary *model = self.dataSource[indexPath.row];
    [cell setData:model];
    return  cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    titleView.backgroundColor = [UIColor colorWithHexString:@"#F8F8F8"];
    UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.bounds.size.width - 30, 60)];
    noticeLabel.text = @"历史授权记录(点击下方选择需要恢复的授权记录，资源均为外部对接，无法保证授权账号一直在线)，部分通道不支持复扫";
    noticeLabel.numberOfLines = 0;
    [noticeLabel setFont:[UIFont systemFontOfSize:14.0]];
    [noticeLabel setTextColor:[UIColor colorWithHexString:@"#99A1A8"]];
    [titleView addSubview:noticeLabel];
    return titleView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.authType == 2) { //扫码授权
        NSDictionary *model = self.dataSource[indexPath.row];
        if ([model[@"isSupportRepeat"] isKindOfClass:[NSNull class]]) {
            [SVProgressHUD showErrorWithStatus:@"该订单不支持复扫"];
             return;
        }
        NSInteger type = [model[@"isSupportRepeat"] integerValue];
        if (type == 2) {
            [SVProgressHUD showErrorWithStatus:@"该订单不支持复扫"];
            return;
        }
        ScanQRVC *vc = [[ScanQRVC alloc] init];
        vc.libraryType = SLT_Native;
        vc.scanCodeType = SCT_QRCode;
        vc.style = [self qqStyle];
        vc.authType = @"1";
        vc.param = @{@"nickname":model[@"platformName"], @"appId": model[@"appId"]};
        vc.authRecord = model;
        [self.navigationController pushViewController:vc animated:YES];
    } else {  //一键授权
        NSDictionary *model = self.dataSource[indexPath.row];
        if (self.didSelectBlock) {
            self.didSelectBlock(model);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

#pragma mark DZNEmptyDataSetSource, DZNEmptyDataSetDelegate

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"icon_empty_nodata"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"没有授权记录o(╯□╰)o";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

//- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
//    return YES;
//}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    NSString *text = @"点击刷新";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [self.tableView.mj_header beginRefreshing];
}


- (void)showInputAlert:(NSDictionary *)model index:(NSInteger)index{
    NSString *message = [NSString stringWithFormat:@"订单授权时间：%@ \nID：%@", [NSString nullToString:model[@"createTime"]], [NSString nullToString:model[@"taskId"]]];
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"订单备注" message:message preferredStyle:
                                  UIAlertControllerStyleAlert];
    // 添加输入框 (注意:在UIAlertControllerStyleActionSheet样式下是不能添加下面这行代码的)
    [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入订单备注";
        NSString *info = [NSString nullToString:model[@"info"]];
        textField.text = info;
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 通过数组拿到textTF的值
        NSString *remark = [[alertVc textFields] objectAtIndex:0].text;
        [self addRemark:remark orid:model[@"id"] index:index model:model];
        //        NSLog(@"ok, %@", [[alertVc textFields] objectAtIndex:0].text);
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    // 添加行为
    [alertVc addAction:action2];
    [alertVc addAction:action1];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)addRemark:(NSString *)remark
             orid:(NSString *)orid
            index:(NSInteger)index
            model:(NSDictionary *)model{
    if (!remark || [remark isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入备注信息"];
        return;
    } else {
        NSMutableDictionary *tmpModel = [[NSMutableDictionary alloc] initWithDictionary:model];
        tmpModel[@"info"] = remark;
        NSMutableArray *tmpDataSource = [[NSMutableArray alloc] initWithArray:self.dataSource];
        tmpDataSource[index] = tmpModel;
        self.dataSource = tmpDataSource;
        [self.tableView reloadData];
        NSString *url = [NSString stringWithFormat:@"%@/setRemark", baseUrl];
        //        @weakify(self);
        [[NetworkingManager manager] postDataWithUrl:url parameters:@{@"remark": remark, @"authOrderId":orid} success:^(id json) {
            //            @strongify(self);
            //            [self setData:(NSDictionary *)json[@"data"]];
        } failure: nil];
    }
    
}

- (LBXScanViewStyle*)qqStyle
{
    //设置扫码区域参数设置
    
    //创建参数对象
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    
    //矩形区域中心上移，默认中心点为屏幕中心点
    style.centerUpOffset = 44;
    
    //扫码框周围4个角的类型,设置为外挂式
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
    
    //扫码框周围4个角绘制的线条宽度
    style.photoframeLineW = 6;
    
    //扫码框周围4个角的宽度
    style.photoframeAngleW = 24;
    
    //扫码框周围4个角的高度
    style.photoframeAngleH = 24;
    
    //扫码框内 动画类型 --线条上下移动
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    
    //线条上下移动图片
    style.animationImage = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];
    
    style.notRecoginitonArea = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    
    return style;
}


@end
