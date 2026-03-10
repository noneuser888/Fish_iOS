//
//  ChargeRecordVC.m
//

#import "ChargeRecordVC.h"
#import "ChargeRecordCell.h"

@interface ChargeRecordVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) NSInteger page;


@end

@implementation ChargeRecordVC

+ (ChargeRecordVC *)vc {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChargeRecordVC" bundle:nil];
    ChargeRecordVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChargeRecordVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 1;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[ChargeRecordCell nib] forCellReuseIdentifier:@"ChargeRecordCell"];
    self.tableView.tableFooterView = [UIView new];
    [self refreshUserInfo];
    @weakify(self)
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        //下拉刷新
        self.page = 1;
        [self requestData];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        self.page += 1;
        [self requestData];
    }];
    [self.tableView.mj_header beginRefreshing];
}

- (void)refreshUserInfo {
    NSDictionary *userInfo = [UserInfoModel shared].userInfo;
    self.phoneLabel.text = userInfo[@"phone"];
    self.nicknameLabel.text = userInfo[@"nickname"];
    self.balanceLabel.text = [NSString stringWithFormat:@"余额:￥%@", userInfo[@"balance"]];
    self.userTypeLabel.text = [UserInfoModel userLevel:[userInfo[@"level"] integerValue]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshUserInfo];
}

- (void)setData:(NSDictionary *)data {
    NSArray *dataArr = data[@"records"];
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

#pragma mark - Network
- (void)requestData{
    NSString *url = [NSString stringWithFormat:@"%@/rechargeRecord/%ld/20", baseUrl, (long)self.page];
    @weakify(self);
    [SVProgressHUD show];
    [[NetworkingManager manager]
     getDataWithUrl:url
     parameters:nil
     success:^(id json) {
        @strongify(self);
        [SVProgressHUD dismiss];
        NSDictionary *data = json[@"data"];
        [self setData:data];
    } failure:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChargeRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChargeRecordCell" forIndexPath:indexPath];
    NSDictionary *model = self.dataSource[indexPath.row];
    [cell setData:model];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *userInfo = [UserInfoModel shared].userInfo;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45)];
    titleView.backgroundColor = [UIColor whiteColor];
    UILabel *title = [[UILabel alloc] init];
    title.numberOfLines = 2;
    title.text = [NSString stringWithFormat:@"我的代理：%@ %@", [NSString nullToString:userInfo[@"myAgency"]], [NSString nullToString:userInfo[@"myAgencyNickname"]]];
    [title setFont:[UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium]];
    [title setTextColor:[UIColor colorWithHexString:@"#333333"]];
    [titleView addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.equalTo(titleView);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width/3);
    }];
    return titleView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

@end
