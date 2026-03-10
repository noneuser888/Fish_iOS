//
//  AuthRecordVC.m
//  星途
//
//  Created by  on 2020/3/19.
//  
//

#import "AuthRecordVC.h"
#import "AuthRecordCell.h"
#import "DateIntervalSelectorPicker.h"
#import "DateIntervalSelectorView.h"

@interface AuthRecordVC ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, copy) void(^scrollCallback)(UIScrollView *scrollView);

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) NSString *startDate;
@property (nonatomic, strong) NSString *endDate;

@end

@implementation AuthRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"授权记录";
    self.page = 1;
    self.tableView = [[UITableView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#F8F8F8"];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[AuthRecordCell xx_nib] forCellReuseIdentifier:@"AuthRecordCell"];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 100.f;
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
        @strongify(self)
        self.page += 1;
        [self requestData];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"筛选" style:UIBarButtonItemStylePlain target:self action:@selector(datePicker)];
    self.navigationItem.rightBarButtonItem = rightItem;
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
            //            [self.tableView.mj_footer endRefreshingWithNoMoreData];
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

- (void)requestData {
    NSString *url = [NSString stringWithFormat:@"%@/authRecord/%ld/20", baseUrl,(long)self.page];
    NSDictionary *parameters;
    if (self.startDate && ![self.startDate isEqualToString:@""] && self.endDate && ![self.endDate isEqualToString:@""]) {
        parameters = @{
            @"startTime": self.startDate,
            @"endTime":self.endDate
        };
    } else {
        parameters = @{@"taskType":@""};
    }
    @weakify(self);
    [[NetworkingManager manager]
     postDataWithUrl:url
     parameters:parameters
     success:^(id json) {
        @strongify(self);
        [self setData:(NSDictionary *)json[@"data"]];
    } failure:^(NSError *error) {
        @strongify(self);
        //        [self setData:@[]];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
    //    return 10;p
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AuthRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AuthRecordCell" forIndexPath:indexPath];
    NSDictionary *model = self.dataSource[indexPath.row];
    [cell setData:model];
    cell.applyAfterSaleBlock = ^{
        [self updateAfterSale:indexPath.row model:model];
    };
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *model = self.dataSource[indexPath.row];
    [self showInputAlert:model index:indexPath.row];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !self.scrollCallback ?: self.scrollCallback(scrollView);
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

//更新售后信息
- (void)updateAfterSale:(NSInteger)index
                  model:(NSDictionary *)model {
    NSMutableDictionary *tmpModel = [[NSMutableDictionary alloc] initWithDictionary:model];
    tmpModel[@"afterSaleStatus"] = @(1);
    NSMutableArray *tmpDataSource = [[NSMutableArray alloc] initWithArray:self.dataSource];
    tmpDataSource[index] = tmpModel;
    self.dataSource = tmpDataSource;
    [self.tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45)];
    titleView.backgroundColor = [UIColor whiteColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.bounds.size.width-30, 45)];
    title.text = @"    点击头像申请售后，一天最多申请10次，请勿恶意申请，否则立即封禁，售后有效时间24小时。";
    title.numberOfLines = 0;
    [title setFont:[UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium]];
    [title setTextColor:[UIColor colorWithHexString:@"#99A1A8"]];
    [titleView addSubview:title];
    return titleView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
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

@end
