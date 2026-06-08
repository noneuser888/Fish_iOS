//
//  PlatformListVC.m
//  星途
//
//  Created by  on 2020/2/24.
//  
//

#import "PlatformListVC.h"
#import "PlatformListCell.h"
#import "ScanQRVC.h"
#import "LoginVC.h"
#import "CGMarqueeView.h"
#import "AuthVC.h"

@interface CustomTitleView : UIView

@end

@implementation CustomTitleView

- (CGSize)intrinsicContentSize {
    return UILayoutFittingExpandedSize;
}

@end

static NSString *platformListTable = @"LoginAuthPlatformList";

@interface PlatformListVC ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SDCycleScrollViewDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSArray *originDataSource;

@property (nonatomic, strong) JQFMDB *db;

@end

@implementation PlatformListVC

+ (PlatformListVC *)vc {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PlatformListVC" bundle:nil];
    PlatformListVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"PlatformListVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [[NSArray alloc] init];
    UIView *titleView = [[CustomTitleView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.backgroundColor = UIColor.whiteColor;
    self.searchBar.placeholder = @"请输入平台名称";
    self.searchBar.delegate = self;
    [titleView addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(titleView);
    }];
    self.navigationItem.titleView = titleView;
    self.navigationController.navigationBar.backgroundColor = UIColor.whiteColor;

    [_tableView registerNib:[PlatformListCell xx_nib] forCellReuseIdentifier:@"PlatformListCell"];
    _tableView.tableFooterView = [UIView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    @weakify(self)
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        //下拉刷新
        [self requestPlatform];
    }];
    
    self.db = [JQFMDB shareDatabase];
    
    NSDictionary *model = @{@"money": @"FLOAT", @"appId":@"TEXT", @"imageUrl": @"TEXT", @"nickname": @"TEXT", @"usableNum":@"INTEGER", @"id":@"INTEGER", @"platformName":@"TEXT", @"tid":@"TEXT"};
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self.db jq_isExistTable:platformListTable]) {
            NSArray *tmpDataSource = [self.db jq_lookupTable:platformListTable dicOrModel:model whereFormat:nil];
            NSDictionary *model = @{@"advice": @"", @"platformList": tmpDataSource, @"banner": @[]};
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setData:model];
            });
        } else {
            [self.db jq_createTable:platformListTable dicOrModel:model];
        }
    });
    
    [self requestPlatform];
}


- (void)setData:(NSDictionary *)data {
    NSArray *platformList = data[@"platformList"];
    self.dataSource = platformList;
    self.originDataSource = platformList;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @weakify(self);
        [self.db jq_inDatabase:^{
            @strongify(self);
            [self.db jq_deleteAllDataFromTable:platformListTable];
            [self.db jq_insertTable:platformListTable dicOrModelArray:platformList];
        }];
    });
    [self.tableView reloadData];
    if ([self.tableView.mj_header isRefreshing]) {
        [self.tableView.mj_header endRefreshing];
    }
}

- (void)requestPlatform {
    NSString *url = [NSString stringWithFormat:@"%@/platform", baseUrl];
    @weakify(self);
    [[NetworkingManager manager] postDataWithUrl:url parameters:nil success:^(id json) {
        @strongify(self);
        [self setData:(NSDictionary *)json[@"data"]];
    } failure:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource) {
        return self.dataSource.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlatformListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlatformListCell" forIndexPath:indexPath];
    NSDictionary *model = self.dataSource[indexPath.row];
    [cell setData:model];
    @weakify(self);
    cell.scanQRActionBlock = ^{
        @strongify(self)
        if (![[UserInfoModel shared] isLogin]) {
            [LoginVC showLoginVC:self];
        } else {
            ScanQRVC *vc = [[ScanQRVC alloc] init];
            vc.libraryType = SLT_Native;
            vc.scanCodeType = SCT_QRCode;
            vc.style = [self qqStyle];
            vc.authType = @"1";
            vc.param = model;
            [self.navigationController pushViewController:vc animated:YES];
        }
    };
    return  cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 75)];
    titleView.backgroundColor = [UIColor whiteColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.bounds.size.width, 25)];
    title.text = @"平台列表";
    [title setFont:[UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium]];
    [title setTextColor:[UIColor colorWithHexString:@"#333333"]];
    [titleView addSubview:title];
    UIView *noticeView = [[UIView alloc] initWithFrame:CGRectMake(0, 25, self.view.bounds.size.width, 50)];
    noticeView.backgroundColor = [UIColor colorWithHexString:@"#F8F8F8"];
    [titleView addSubview:noticeView];
    UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.bounds.size.width - 30, 50)];
    noticeLabel.text = @"选择错误将不会跳转且会扣费，所以请务必选择正确的与之对应的图标和文字！";
    noticeLabel.numberOfLines = 2;
    [noticeLabel setFont:[UIFont systemFontOfSize:14.0]];
    [noticeLabel setTextColor:[UIColor colorWithHexString:@"#99A1A8"]];
    [noticeView addSubview:noticeLabel];
    return titleView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *model = self.dataSource[indexPath.row];
    NSString *scopeStr = model[@"scope"];
    if (scopeStr.length > 0) {
        NSArray *scopeArr = [scopeStr componentsSeparatedByString:@"&"];
        if (scopeArr.count >= 2) {
            NSString *scope = [scopeArr[0] componentsSeparatedByString:@"="].lastObject;
            NSString *state = [scopeArr[1] componentsSeparatedByString:@"="].lastObject;
            NSDictionary *param = @{@"appid": model[@"appId"],
                                    @"bundleid": @"null",
                                    @"scope": scope,
                                    @"state": state
            };
            AuthVC *authVc = [AuthVC initWithParameter:param];
            [self.navigationController pushViewController:authVc animated:true];
            return;
        }
    }
    [SVProgressHUD showErrorWithStatus:@"该平台不支持静态授权"];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
    //    self.searchBar.resignFirstResponder = YES;
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

- (void)localSearchWithKey:(NSString *)key {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSDictionary *model in self.originDataSource) {
        NSString *platformName = @"";
        NSString *nickname = @"";
        if (model[@"nickname"]) {
            nickname = model[@"nickname"];
        }
        if (model[@"platformName"]) {
            platformName = model[@"platformName"];
        }
        if(nickname == NULL || platformName == NULL){
            NSLog(@"");
        }
        NSLog(@"model:%@",model);
        if ([nickname containsString:key] || [platformName containsString:key]) {
            [result addObject: model];
        }
    }
    if (key && key.length > 0) {
        self.dataSource = result;
    } else {
        self.dataSource = self.originDataSource;
    }
    [self.tableView reloadData];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self localSearchWithKey:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self localSearchWithKey:self.searchBar.text];
}


@end
