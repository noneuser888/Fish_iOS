//
//  HomeVC.m
//  星途

//

#import "HomeVC.h"
#import "NavController.h"
#import "HomeProjectCell.h"
#import "PopMenuView.h"
#import "PlatformListVC.h"
#import "AuthRecordVC.h"
#import "LoginVC.h"
#import "UserListVC.h"
#import "ChargeRecordVC.h"
#import "MyAgencyInfoVC.h"
#import "HomePopupVC.h"
#import <SafariServices/SafariServices.h>

@interface HomeVC ()<UITableViewDelegate, UITableViewDataSource, SDCycleScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@property (weak, nonatomic) IBOutlet UIView *bannerContainerView;
@property (weak, nonatomic) IBOutlet UIView *agencyView;
@property (weak, nonatomic) IBOutlet UIView *usersView;

@property (weak, nonatomic) IBOutlet UIImageView *agencyIconImg;
@property (weak, nonatomic) IBOutlet UIImageView *userIconImg;
@property (weak, nonatomic) IBOutlet UILabel *agencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *inviteUrlLabel;


@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *bannerData;

@property (nonatomic, assign) NSInteger number;

@end

@implementation HomeVC

+ (instancetype)shared {
    static HomeVC *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HomeVC" bundle:nil];
        HomeVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"HomeVC"];
        _instance = vc;
    });
    return _instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.number = 0;
    self.fd_prefersNavigationBarHidden = YES;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.dataSource = [[NSArray alloc] init];
    [self.tableView registerNib:[HomeProjectCell nib] forCellReuseIdentifier:@"HomeProjectCell"];
    
    if ([UIScreen mainScreen].bounds.size.height < 812) {
        self.topViewHeightConstraint.constant = 80;
    } else {
        self.topViewHeightConstraint.constant = 104;
    }
    
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:[self bannerFrame] delegate:self placeholderImage:[UIImage imageNamed:@"banner_placeholder"]];
    self.cycleScrollView.backgroundColor = [UIColor colorWithHexString:@"#FF111F"];
    self.cycleScrollView.showPageControl = NO;
    [self.bannerContainerView addSubview:self.cycleScrollView];
    
    @weakify(self)
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        //下拉刷新
        [self homeRequest];
        if ([UserInfoModel shared].isLogin) {
            [UserInfoModel requestInfo:^(NSDictionary * _Nullable data) {
                @strongify(self);
                [self refreshUserInfo];
            }];
        }
    }];
    [self.tableView.mj_header beginRefreshing];
    
    dispatch_queue_after_S(0.5, ^{
        @strongify(self);
        [self getAdRequest];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserInfo) name:@"LoginSucess" object:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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

- (CGRect)bannerFrame {
    CGFloat bannerHeight = ([UIScreen mainScreen].bounds.size.width - 30) / 345 * 130;
    CGRect bannerFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 30, bannerHeight);
    return bannerFrame;
}

- (void)refreshUserInfo {
    if ([UserInfoModel shared].isLogin) {
        NSDictionary *userInfo = [UserInfoModel shared].userInfo;
        self.phoneLabel.text = [NSString nullToString:userInfo[@"phone"]];
        self.nickNameLabel.text = [NSString stringWithFormat:@"%@  %@", [NSString nullToString:userInfo[@"nickname"]], [UserInfoModel userLevel:[userInfo[@"level"] integerValue]]];
        self.balanceLabel.text = [NSString stringWithFormat:@"余额:￥%@", userInfo[@"balance"]];
        self.inviteUrlLabel.text = [NSString stringWithFormat:@"邀请链接：%@\n邀请码：%@", [NSString nullToString:userInfo[@"inviteUrl"]], [NSString nullToString:userInfo[@"inviteCode"]]];
        NSInteger level = [userInfo[@"level"] integerValue];
        switch (level) {
            case 0:
                self.agencyIconImg.image = [UIImage imageNamed:@"dailixiangguan"];
                self.agencyLabel.text = @"代理相关";
                self.agencyView.hidden = NO;
                self.userIconImg.image = [UIImage imageNamed:@"chongzhijilu"];
                self.userLabel.text = @"充值记录";
                self.usersView.hidden = NO;
                break;
            case 1:
                self.agencyIconImg.image = [UIImage imageNamed:@"dailiguanli"];
                self.agencyLabel.text = @"代理管理";
                self.agencyView.hidden = NO;
                self.userIconImg.image = [UIImage imageNamed:@"yonghuguanli"];
                self.userLabel.text = @"用户管理";
                self.usersView.hidden = NO;
                break;
            case 2:
                self.agencyView.hidden = YES;
                self.userIconImg.image = [UIImage imageNamed:@"yonghuguanli"];
                self.userLabel.text = @"用户管理";
                self.usersView.hidden = NO;
            default:
                break;
        }
    } else {
        self.phoneLabel.text = @"***";
        self.nickNameLabel.text = @"***";
        self.balanceLabel.text = @"***";
        self.inviteUrlLabel.text = @"邀请链接";
        self.agencyView.hidden = YES;
        self.usersView.hidden = YES;
    }
    
}

- (void)setData:(NSDictionary *)data {
    NSArray *tmpBanner = data[@"banner"];
    if (tmpBanner && tmpBanner.count > 0) {
        self.bannerData = tmpBanner;
        NSMutableArray *bannerArray = [[NSMutableArray alloc] init];
        for (NSDictionary *bannerModel in tmpBanner) {
            [bannerArray addObject: bannerModel[@"imgUrl"]];
        }
        self.cycleScrollView.imageURLStringsGroup = bannerArray;
    }
    NSArray *projectArray = data[@"project"];
    if (projectArray) {
        self.dataSource = projectArray;
    }
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}


- (void)homeRequest {
    NSString *url = [NSString stringWithFormat:@"%@/home", baseUrl];
    //    NSDictionary *param = @{@"email": email, @"code": code};
    @weakify(self);
    [SVProgressHUD show];
    [[NetworkingManager manager] getDataWithUrl:url parameters:nil success:^(id json) {
        @strongify(self);
        [SVProgressHUD dismiss];
        NSDictionary *data = json[@"data"];
        [self setData:data];
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)modifyNicknameRequest:(NSString *)nickname {
    if(nickname.length > 20) {
        [SVProgressHUD showErrorWithStatus:@"昵称最大长度为20位"];
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@/updateNickname", baseUrl];
    NSDictionary *param = @{@"nickname": nickname};
    @weakify(self);
    [SVProgressHUD show];
    [[NetworkingManager manager] postDataWithUrl:url parameters:param success:^(id json) {
        @strongify(self);
        [SVProgressHUD showSuccessWithStatus:@"昵称修改成功"];
        [UserInfoModel requestInfo:^(NSDictionary * _Nullable data) {
            @strongify(self);
            [self refreshUserInfo];
        }];
    } failure:nil];
}

// 获取广告弹窗
- (void)getAdRequest {
    NSString *url = [NSString stringWithFormat:@"%@/popups",baseUrl];
    [[NetworkingManager manager] getDataWithUrl:url parameters:nil success:^(id json) {
        NSArray *dataArray = json[@"data"];
        if (dataArray && dataArray.count > 0) {
            NSDictionary *data = dataArray.firstObject;
            NSDictionary *popAds = (NSDictionary *)[[StoreService shared] getData:@"HomePopupVC.AD"];
            if (popAds) {
                double saveDate = 0.0;
                if (popAds[@"saveDate"]) {
                    saveDate = [popAds[@"saveDate"] doubleValue];
                }
                NSString *saveImgUrl = popAds[@"imgUrl"];
                NSString *imgUrl = data[@"imgUrl"];
                double currentTime = [[NSDate date] timeIntervalSince1970];
                if ([saveImgUrl isEqualToString:imgUrl] && currentTime - saveDate <= 60*60*24*2) {
                    return;
                }
            }
            NSString *webLink = [NSString nullToString:data[@"webLink"]];
            NSDictionary *adData = @{
                @"imgUrl":data[@"imgUrl"],
                @"webLink":webLink,
                @"saveDate":@([[NSDate date] timeIntervalSince1970])
            };
            [[StoreService shared] setData:adData forKey:@"HomePopupVC.AD"];
            HomePopupVC *vc = [HomePopupVC vc];
            vc.params = data;
            NavController *nav = [[NavController alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:nav animated:NO completion:nil];
        }
    } failure:nil];
}

- (IBAction)showPlatform:(id)sender {
//    NSURL *url = [NSURL URLWithString:@"wx5da61cd09ba4b981://oauth?code=081f9Ecu0VVdvf1By4eu0VmFcu0f9Ecl&state=kWeiXinState"];
//    [[UIApplication sharedApplication] openURL:url];
    PlatformListVC *vc = [PlatformListVC vc];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)showAuthRecord:(id)sender {
    if ([UserInfoModel shared].isLogin) {
        AuthRecordVC *vc = [[AuthRecordVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [LoginVC showLoginVC:self];
    }
}

- (IBAction)showAgency:(id)sender {
    if ([UserInfoModel shared].isLogin) {
        NSDictionary *userInfo = [UserInfoModel shared].userInfo;
        NSInteger level = [userInfo[@"level"] integerValue];
        if (level == 0) {
            //代理相关
            MyAgencyInfoVC *vc = [MyAgencyInfoVC vc];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            UserListVC *vc = [UserListVC vcWithType:1];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        [LoginVC showLoginVC:self];
    }
}

- (IBAction)showUsers:(id)sender {
    if ([UserInfoModel shared].isLogin) {
        NSDictionary *userInfo = [UserInfoModel shared].userInfo;
        NSInteger level = [userInfo[@"level"] integerValue];
        if (level == 0) {
            ChargeRecordVC *vc = [ChargeRecordVC vc];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            UserListVC *vc = [UserListVC vcWithType:2];
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else {
        [LoginVC showLoginVC:self];
    }
}

- (IBAction)showMoreAction:(id)sender {
    @weakify(self);
    NSArray *titles = [UserInfoModel shared].isLogin ? @[@"账号类型",@"修改昵称",@"常见问题",@"退出登录"]:@[@"账号类型", @"常见问题", @"登录"];
    NSString *faqUrl = [NSString stringWithFormat:@"%@/faq", baseUrl];
    [PopMenuView showPopMenuWithIconImageNames:@[] titles:titles originPosition:CGPointMake([UIScreen mainScreen].bounds.size.width-25, 25) heightOfItem:40 widthOfView:150 backgroundColorOfView:[UIColor whiteColor] needSeparatorLine:YES selectedItemComplete:^(NSInteger currentIndex) {
        @strongify(self);
        switch (currentIndex) {
            case 0: //账号类型
            {
                [self showAlert];
            }
                break;
            case 1: //修改昵称
            {
                if ([UserInfoModel shared].isLogin) {
                    NSDictionary *userInfo = [UserInfoModel shared].userInfo;
                    [self showInputAlert:userInfo];
                } else {
                    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:faqUrl]];
                    [self presentViewController:safari animated:YES completion:nil];
                }
            }
                break;
            case 2: //常见问题
            {
                if ([UserInfoModel shared].isLogin) {
                    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:faqUrl]];
                    [self presentViewController:safari animated:YES completion:nil];
                } else {
                    [LoginVC showLoginVC:self];
                }
            }
                break;
            case 3: //退出登录
            {
                [self alert:@"退出登录" message:@"您确定要退出登录吗？" handler:^(UIAlertAction *action) {
                    @strongify(self);
                    [[UserInfoModel shared] userLogout];
                    self.tabBarController.selectedIndex = 0;
                }];
            }
                break;
            default:
                break;
        }
    }];
}

- (IBAction)copyAction:(id)sender {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    board.string = self.inviteUrlLabel.text;
    [SVProgressHUD showSuccessWithStatus:@"邀请链接复制成功"];
}

- (IBAction)avatarClickAction:(id)sender {
    if (self.number <= 15) {
        self.number += 1;
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UserInfoModel.Debug"];
        [SVProgressHUD showInfoWithStatus:@"Debug模式开启"];
        return;
    }
}

- (void)showInputAlert:(NSDictionary *)model {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"昵称" message:@"添加/修改昵称" preferredStyle:
                                  UIAlertControllerStyleAlert];
    // 添加输入框 (注意:在UIAlertControllerStyleActionSheet样式下是不能添加下面这行代码的)
    [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入昵称";
        NSString *info = [NSString nullToString:model[@"nickname"]];
        textField.text = info;
    }];
    @weakify(self);
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        // 通过数组拿到textTF的值
        NSString *nickname = [[alertVc textFields] objectAtIndex:0].text;
        [self modifyNicknameRequest:nickname];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    // 添加行为
    [alertVc addAction:action2];
    [alertVc addAction:action1];
    [self presentViewController:alertVc animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeProjectCell" forIndexPath:indexPath];
    [cell setData:self.dataSource[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *model = self.dataSource[indexPath.row];
    NSString *webLink = [NSString nullToString:model[@"webLink"]];
    if (![webLink isEqualToString:@""]) {
        WKWebViewController *wkVC = [[WKWebViewController alloc] init];
        [wkVC loadWithURLString:webLink];
        [self.navigationController pushViewController:wkVC animated:true];
    }
}


#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    NSDictionary *model = self.bannerData[index];
    NSString *webUrl = model[@"webLink"];
    if (webUrl && webUrl.length > 0) {
        WKWebViewController *wkWebVC = [[WKWebViewController alloc] init];
        [wkWebVC loadWithURLString:webUrl];
        [self.navigationController pushViewController:wkWebVC animated:true];
    }
}

- (void)refeshReadNum:(NSString *)idNo {
    NSString *url = [NSString stringWithFormat:@"%@/updateReadNumber/%@", baseUrl, idNo];
    [[NetworkingManager manager] postDataWithUrl:url parameters:nil success:^(id json) {
        NSLog(@"阅读数量添加成功");
    } failure: nil];
}


- (void)alert:(NSString*) title message:(NSString*) message handler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:handler];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertCtrl addAction:action];
    [alertCtrl addAction:cancelAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}



- (void)showAlert {
    //初始化一个UIAlertController的警告框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"账号类型选择" message:@"请选择需要的账号类型" preferredStyle:UIAlertControllerStyleAlert];
    //初始化一个UIAlertController的警告框将要用到的UIAlertAction style defalut
    NSString *type = [[UserInfoModel shared] getAccountType];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"普通账号" style:[type isEqualToString:@"1"]?UIAlertActionStyleDestructive:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UserInfoModel shared] setAccountType:@"1"];
        NSLog(@"t提示框上的按钮 CANCLE 被点击了");
    }];
    //初始化一个UIAlertController的警告框将要用到的UIAlertAction style cancle
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"高级账号" style:[type isEqualToString:@"2"]?UIAlertActionStyleDestructive:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UserInfoModel shared] setAccountType:@"2"];
        NSLog(@"t提示框上的按钮 OK 被点击了");
    }];
    //初始化一个UIAlertController的警告框将要用到的UIAlertAction style cancle
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"专属账号" style:[type isEqualToString:@"3"]?UIAlertActionStyleDestructive:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [[UserInfoModel shared] setAccountType:@"3"];
        NSLog(@"t提示框上的按钮 Other 被点击了");
    }];
    //将初始化好的UIAlertAction添加到UIAlertController中
    [alertController addAction:okAction];
    [alertController addAction:cancleAction];
    [alertController addAction:otherAction];
    //将初始化好的提示框显示出来
    [self presentViewController:alertController animated:true completion:nil];

}

@end
