//
//  UserListVC.m
//

#import "UserListVC.h"
#import "UserListCell.h"
#import "ChargeVC.h"
#import "ChargeRecordVC.h"

@interface UserListVC ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTypesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userBgImageView;
@property (strong, nonatomic) UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, assign) NSInteger level;

@end

@implementation UserListVC

+ (UserListVC *)vcWithType:(NSInteger)type {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserListVC" bundle:nil];
    UserListVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"UserListVC"];
    vc.type = type;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *userInfo = [UserInfoModel shared].userInfo;
    self.level = [userInfo[@"level"] integerValue];
    self.fd_prefersNavigationBarHidden = YES;
    self.titleLabel.text = self.type == 1 ? @"代理管理":@"用户管理";
    if ([UIScreen mainScreen].bounds.size.height < 812) {
        self.topViewHeightConstraint.constant = 20;
    } else {
        self.topViewHeightConstraint.constant = 44;
    }
    self.page = 1;
    self.phone = @"";
    self.dataSource = [[NSArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UserListCell nib] forCellReuseIdentifier:@"UserListCell"];
    [self refreshUserInfo];
    @weakify(self)
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        //下拉刷新
        self.page = 1;
        [self requestData:nil indexPath:nil isShow:NO];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        self.page += 1;
        [self requestData:nil indexPath:nil isShow:NO];
    }];
    [self.tableView.mj_header beginRefreshing];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshUserInfo];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)refreshUserInfo {
    NSDictionary *userInfo = [UserInfoModel shared].userInfo;
    self.phoneLabel.text = userInfo[@"phone"];
    self.nicknameLabel.text = userInfo[@"nickname"];
    self.balanceLabel.text = [NSString stringWithFormat:@"余额:￥%@", userInfo[@"balance"]];
    self.userTypesLabel.text = [UserInfoModel userLevel:[userInfo[@"level"] integerValue]];
}

- (void)setData:(NSDictionary *)data {
    NSArray *dataArr = data[@"records"];
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

- (void)singleRefresh:(NSDictionary *)model
            indexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = ((NSArray *)model[@"records"]).firstObject;
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithArray:self.dataSource];
    [tmpArray replaceObjectAtIndex:indexPath.row withObject:item];
    self.dataSource = tmpArray;
    [self.tableView reloadData];
}

- (void)showInputAlert:(NSDictionary *)model index:(NSInteger)index{
    NSString *message = [NSString stringWithFormat:@"给用户 %@ 添加备注信息", model[@"phone"]];
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"备注" message:message preferredStyle:
                                  UIAlertControllerStyleAlert];
    // 添加输入框 (注意:在UIAlertControllerStyleActionSheet样式下是不能添加下面这行代码的)
    [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入备注信息";
        NSString *info = [NSString nullToString:model[@"info"]];
        textField.text = info;
    }];
    @weakify(self);
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // 通过数组拿到textTF的值
        @strongify(self);
        NSString *remark = [[alertVc textFields] objectAtIndex:0].text;
        [self addRemarkRequest:remark model:model index:index];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    // 添加行为
    [alertVc addAction:action2];
    [alertVc addAction:action1];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (IBAction)moreAction:(id)sender {
    [self.navigationController pushViewController:[ChargeRecordVC vc] animated:YES];
}

#pragma mark - Network
- (void)requestData:(NSString * _Nullable)phone
          indexPath:(NSIndexPath * _Nullable)indexPath
             isShow:(BOOL)isShow{
    NSString *url;
    switch (self.type) {
        case 1: //代理列表
            url = [NSString stringWithFormat:@"%@/myAgencyList/%ld/20", baseUrl, (long)self.page];
            break;
        case 2: //用户列表
            url = [NSString stringWithFormat:@"%@/myUserList/%ld/20", baseUrl, (long)self.page];
        default:
            break;
    }
    NSDictionary *parameters;
    if (phone) {
        parameters = @{@"phone":phone};
    } else {
        parameters = @{@"phone":@""};
    }
    @weakify(self);
    if (isShow) {
        [SVProgressHUD show];
    }
    [[NetworkingManager manager]
     postDataWithUrl:url
     parameters:parameters
     success:^(id json) {
        @strongify(self);
        [SVProgressHUD dismiss];
        NSDictionary *data = json[@"data"];
        if (indexPath) {
            [self singleRefresh:data indexPath:indexPath];
        } else {
            [self setData:data];
        }
        
    } failure:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)addRemarkRequest:(NSString *)remark
                   model:(NSDictionary *)model
                   index:(NSInteger)index {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:model];
    @weakify(self);
    NSString *url = [NSString stringWithFormat:@"%@/addRemark", baseUrl];
    [SVProgressHUD show];
    [[NetworkingManager manager]
     postDataWithUrl:url
     parameters:@{@"id":userInfo[@"id"],@"remark":remark}
     success:^(id json) {
        @strongify(self);
        [SVProgressHUD showSuccessWithStatus:@"添加备注成功"];
        [userInfo setObject:remark forKey:@"remark"];
        NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithArray:self.dataSource];
        tmpArray[index] = userInfo;
        self.dataSource = tmpArray;
        [self.tableView reloadData];
    } failure:nil];
}

- (void)bannedRequest:(NSDictionary *)userInfo index:(NSInteger)index {
    @weakify(self);
    NSString *message;
    NSMutableDictionary *model = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    __block NSInteger userStatus = [model[@"status"] integerValue];
    if (userStatus == 0) {
        message = [NSString stringWithFormat:@"您确定要封禁用户 %@，封禁之后，该用户将不能登录，直到解封。", userInfo[@"phone"]];
    } else {
        message = [NSString stringWithFormat:@"您确定要解封用户 %@，解封之后，该用户将可以使用所有功能", userInfo[@"phone"]];
    }
    [self alert:@"提示" message:message handler:^(UIAlertAction *action) {
        NSString *url = [NSString stringWithFormat:@"%@/bannedUser/%@", baseUrl, userInfo[@"id"]];
        @strongify(self);
        [SVProgressHUD show];
        [[NetworkingManager manager] postDataWithUrl:url parameters:nil success:^(id json) {
            @strongify(self);
            [SVProgressHUD showSuccessWithStatus:userStatus == 0 ? @"封禁用户成功":@"解封用户成功"];
            if (userStatus == 0) {
                userStatus = 1;
            } else {
                userStatus = 0;
            }
            [model setObject:@(userStatus) forKey:@"status"];
            NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithArray:self.dataSource];
            tmpArray[index] = model;
            self.dataSource = tmpArray;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            @strongify(self);
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        }];
    }];
}

- (void)upgradeUserRequest:(NSDictionary *)userInfo index:(NSInteger)index {
     @weakify(self);
    [self alert:@"升级代理"
        message:[NSString stringWithFormat:@"您确定要将用户 %@ ，升级为代理吗？", userInfo[@"phone"]]
        handler:^(UIAlertAction *action) {
        NSString *url = [NSString stringWithFormat:@"%@/userUpgrade/%@", baseUrl, userInfo[@"id"]];
        @strongify(self);
        [SVProgressHUD show];
        [[NetworkingManager manager] postDataWithUrl:url parameters:nil success:^(id json) {
            @strongify(self);
            [SVProgressHUD showSuccessWithStatus:@"升级代理成功"];
            NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithArray:self.dataSource];
            [tmpArray removeObjectAtIndex:index];
            self.dataSource = tmpArray;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            @strongify(self);
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        }];
    }];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserListCell" forIndexPath:indexPath];
    NSDictionary *model = self.dataSource[indexPath.row];
    [cell setData:model];
    if (self.type != 1 && self.level == 1) {
        cell.upgradeUserBtn.hidden = NO;
    } else {
        cell.upgradeUserBtn.hidden = YES;
    }
    @weakify(self);
    cell.addRemarkBlock = ^{
        @strongify(self);
        [self showInputAlert:model index:indexPath.row];
    };
    cell.bannedBlock = ^{
        @strongify(self);
        [self bannedRequest:model index:indexPath.row];
    };
    cell.chargeBlock = ^ {
        @strongify(self);
        ChargeVC *vc = [ChargeVC vc:model ChargeBlock:^{
            @strongify(self);
            [self refreshUserInfo];
            [self requestData:model[@"phone"] indexPath:indexPath isShow:NO];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    };
    cell.upgradeUserBlock = ^{
        [self upgradeUserRequest:model index:indexPath.row];
    };
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *userInfo = [UserInfoModel shared].userInfo;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45)];
    titleView.backgroundColor = [UIColor whiteColor];
    CGFloat searchBarWidth = [UIScreen mainScreen].bounds.size.width * 0.4;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width-searchBarWidth-30, 45)];
    title.text = [NSString stringWithFormat:@"我的代理：%@ %@", [NSString nullToString:userInfo[@"myAgency"]], [NSString nullToString:userInfo[@"myAgencyNickname"]]];
    title.numberOfLines = 2;
    [title setFont:[UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium]];
    title.minimumScaleFactor = 0.5;
    [title setAdjustsFontSizeToFitWidth:YES];
    [title setTextColor:[UIColor colorWithHexString:@"#333333"]];
    [titleView addSubview:title];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-searchBarWidth-15, 0, searchBarWidth, 45)];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.barTintColor = [UIColor colorWithHexString:@"#333333"];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"请输入账号";
    [self.searchBar setFont:12.0];
    [titleView addSubview:self.searchBar];
    return titleView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *phone = searchBar.text;
    [self requestData:phone indexPath:nil isShow:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *phone = searchBar.text;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchRequest:) object:nil];
    [self performSelector:@selector(searchRequest:) withObject:phone afterDelay:0.5];
}

- (void)searchRequest:(NSString *)phone {
    [self requestData:phone indexPath:nil isShow:NO];
}

- (void)alert:(NSString*) title message:(NSString*) message handler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:handler];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertCtrl addAction:action];
    [alertCtrl addAction:cancelAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}


@end
