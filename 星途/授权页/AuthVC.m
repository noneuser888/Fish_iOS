//
//  AuthVC.m
//  星途
//
//  Created by  on 2020/2/25.
//  
//

#import "AuthVC.h"
#import "UIWebView+DKProgress.h"
#import "DKProgressLayer.h"
#import "LoginVC.h"
#import "LBXScanNative.h"
#import "ApplyAddPlatformVC.h"
#import "RepeatScanRecordVC.h"
#import "LBXScanNative+App.h"
//#import "UIViewController+MMDrawerController.h"



@interface AuthVC ()<UIWebViewDelegate>


@property (nonatomic, strong)UIWebView *webView;
//返回按钮
@property (nonatomic, strong)UIBarButtonItem* customBackBarItem;
//底部容器
@property (nonatomic, strong)UIView *bottomContainerView;

@property (nonatomic, strong)NSString *wxUrl;
@property (nonatomic, strong)NSString *appid;

@property (nonatomic, strong)NSString *qrCodeUrl;
@property (nonatomic, strong)NSString *qrCodeContent;
@property (nonatomic, strong)NSString *wxNickname;
@property (nonatomic, strong)NSString *authAvatar;
@property (nonatomic, strong)NSString *wxUserNickName;
@property (nonatomic, strong)UIImage *authAvatarImg;

@property (nonatomic, strong)NSDictionary *requestParameter;

@property (nonatomic, assign)NSInteger authType; //1: 显示二维码 2：一键授权

@property (nonatomic, assign) NSInteger requestNumber;

@property (nonatomic, strong) NSString *authOrderId;

@property (nonatomic, strong) NSDictionary *currentRecord;

///定时器
@property (nonatomic, strong) CLGCDTimer *timer;
/**响应次数*/
@property (nonatomic, assign) NSInteger actionTimes;
/**开始的次数*/
@property (nonatomic, assign) NSInteger startActionTimes;
///离开的时间
@property (nonatomic, assign) NSTimeInterval resignSystemUpTime;
///恢复的时间
@property (nonatomic, assign) NSTimeInterval becomeSystemUpTime;
///离开总时间
@property (nonatomic, assign) NSInteger leaveTime;


@end

@implementation AuthVC

+ (instancetype)initWithURL:(nullable NSString *)url {
    AuthVC *authVC = [[self alloc] init];
    if (url) {
        authVC.wxUrl = url;
    } else {
        if ([UserInfoModel shared].isLogin) {
            authVC.wxUrl =  [NSString stringWithFormat:@"%@/authPage?agencyId=%@", baseUrl, [UserInfoModel shared].agencyId];
        } else {
            authVC.wxUrl = [NSString stringWithFormat:@"%@/authPage", baseUrl];
        }
    }
    return authVC;
}

+ (instancetype)initWithParameter:(NSDictionary *)parameter {
    
    NSString *qrconnect = @"/connect/app/qrconnect";
    NSString *appid = parameter[@"appid"];
    NSString *bundleid = parameter[@"bundleid"];
    NSString *scope = parameter[@"scope"];
    NSString *state = parameter[@"state"];
    NSString *url = [NSString stringWithFormat:@"%@%@?appid=%@&bundleid=%@&scope=%@&state=%@", wx_base_url, qrconnect, appid, bundleid, scope, state];
    AuthVC *authVC = [self initWithURL:url];
    authVC.appid = appid;
    authVC.requestParameter = parameter;
    return authVC;
}

- (void)loadWithURL:(NSString *)url {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    //    [request addValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/7.0.0(0x17000024) NetType/WIFI Language/zh_CN" forHTTPHeaderField:@"User-Agent"];
    //    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: url]];
    self.wxUrl = url;
    [self.webView loadRequest:request];
}

- (void)loadWithParameter:(NSDictionary *)parameter {
    if (self.webView.canGoBack) {
        [self.webView goBack];
        @weakify(self);
        dispatch_queue_after_S(0.6, ^{
            @strongify(self);
            NSString *qrconnect = @"/connect/app/qrconnect";
            NSString *appid = parameter[@"appid"];
            NSString *bundleid = parameter[@"bundleid"];
            self.appid = appid;
            self.requestParameter = parameter;
            NSString *scope = parameter[@"scope"];
            NSString *state = parameter[@"state"];
            NSString *url = [NSString stringWithFormat:@"%@%@?appid=%@&bundleid=%@&scope=%@&state=%@", wx_base_url, qrconnect, appid, bundleid, scope, state];
            [self loadWithURL:url];
        });
    } else {
        NSString *qrconnect = @"/connect/app/qrconnect";
        NSString *appid = parameter[@"appid"];
        NSString *bundleid = parameter[@"bundleid"];
        self.appid = appid;
        self.requestParameter = parameter;
        NSString *scope = parameter[@"scope"];
        NSString *state = parameter[@"state"];
        NSString *url = [NSString stringWithFormat:@"%@%@?appid=%@&bundleid=%@&scope=%@&state=%@", wx_base_url, qrconnect, appid, bundleid, scope, state];
        [self loadWithURL:url];
        //        [self.view addSubview:self.webView];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"授权";
    self.view.backgroundColor = [UIColor colorWithHexString:@"#F8F8F8"];
    
    if (@available(iOS 11.0, *)) {
        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    self.startActionTimes = 0;
    self.fd_interactivePopDisabled = YES;
// #if !DEBUG
//     if ([configServer isEqualToString:@"1"] && [UserInfoModel checkHTTPEnable]) {
//         if (![UserInfoModel isHTTPS]) {
//             [self alert:@"警告⚠️" message:@"当前环境不安全" cancelEnable:NO handler:^(UIAlertAction *action) {
//                 [self.navigationController popViewControllerAnimated:YES];
//             } cancelHandler:nil];
//             return;
//         }
//     }
// #endif
    UIWebView *webView = [[UIWebView alloc] init];
    NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *customUserAgent = [userAgent stringByAppendingFormat:@" %@", @"MicroMessenger/7.0.0(0x17000024) NetType/WIFI Language/zh_CN"];
    if (![userAgent hasSuffix:@"MicroMessenger/7.0.0(0x17000024) NetType/WIFI Language/zh_CN"]) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"User-Agent": customUserAgent, @"UserAgent": customUserAgent}];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.requestNumber = 0;
    self.authType = 1;
    self.webView.delegate = self;
    self.webView.dk_progressLayer = [[DKProgressLayer alloc] initWithFrame:CGRectMake(0, NavHight, self.view.bounds.size.width, 1.4)];
    self.webView.dk_progressLayer.progressColor = [UIColor colorWithRed:77.0/255 green:122.0/255 blue:253.0/255 alpha:1];
    self.webView.dk_progressLayer.progressStyle = DKProgressStyle_Noraml;
    [self.navigationController.navigationBar.layer addSublayer:self.webView.dk_progressLayer];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: self.wxUrl]];
    [self.webView loadRequest:request];
    
    UIBarButtonItem *roadLoad = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadClicked)];
    //    UIBarButtonItem *repeatScan = [[UIBarButtonItem alloc] initWithTitle:@"复扫" style:UIBarButtonItemStylePlain target:self action:@selector(repeatScanClicked)];
    self.navigationItem.rightBarButtonItems = @[roadLoad];
    
    @weakify(self);
    self.timer = [[CLGCDTimer alloc] initWithInterval:1 delaySecs:0 queue:dispatch_get_main_queue() repeats:YES action:^(NSInteger actionTimes) {
        @strongify(self);
        self.actionTimes = actionTimes;
        if (self.startActionTimes > 0 && actionTimes - self.startActionTimes >= 5 * 60 + 10) {
            NSLog(@"请求耗时任务取消");
            self.startActionTimes = 0;
            self.fd_interactivePopDisabled = YES;
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            [SVProgressHUD showWithStatus:@"授权超时，正在申请售后，请等待..."];
            [self applyAfterSaleWithOrderId:self.authOrderId];
        }
    }];
    [self.timer start];
    [self addNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.currentRecord = [RepeatScanRecordVC currentAuthRecord];
    if (self.currentRecord && self.wxNickname && [self.appid isEqualToString:self.currentRecord[@"appId"]]) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@(复扫)", self.wxNickname];
    } else {
        self.navigationItem.title = self.wxNickname;
    }
}

//MARK:JmoVxia---添加系统活动通知
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}
//MARK:JmoVxia---进入后台
- (void)applicationWillResignActive:(NSNotification *)notification {
    self.resignSystemUpTime = [NSDate uptimeSinceLastBoot];
    [self.timer suspend];
}
//MARK:JmoVxia---进入前台
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    self.becomeSystemUpTime = [NSDate uptimeSinceLastBoot];
    //计算离开时间，需要将每次离开时间叠加
    self.leaveTime += (NSInteger)floor(self.becomeSystemUpTime - self.resignSystemUpTime);
    [self.timer resume];
}

#pragma mark - UI
- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_webView];
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.mas_equalTo(0);
        }];
    }
    return  _webView;
}

- (UIView *)bottomContainerView {
    if (!_bottomContainerView) {
        _bottomContainerView = [[UIView alloc] init];
        _bottomContainerView.backgroundColor = [UIColor clearColor];
        [self.view insertSubview:_bottomContainerView aboveSubview:self.webView];
        //        [self.view addSubview: _bottomContainerView];
        _bottomContainerView.hidden = YES;
        [_bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(75);
            make.bottom.mas_equalTo(-40);
        }];
        
        UIStackView *stackView = [[UIStackView alloc] init];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.distribution = UIStackViewDistributionFillEqually;
        stackView.alignment = UIStackViewDistributionFill;
        stackView.spacing = 20;
        NSArray *titleArray = @[@"新号", @"老号", @"复扫", @"显码"];
        NSArray *imageNamedArray = @[@"yijianshouquan", @"laohao", @"fusao", @"xianma"];
        for (NSInteger i = 0; i < titleArray.count; i++) {
            UIView *containerView = [self setupCustomBtn:titleArray[i] imageName:imageNamedArray[i] index:i];
            [stackView addArrangedSubview:containerView];
        }
        [_bottomContainerView addSubview:stackView];
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.centerX.mas_equalTo(_bottomContainerView.mas_centerX);
            make.width.mas_equalTo(235);
        }];
        
    }
    return _bottomContainerView;
}

- (UIView *)setupCustomBtn:(NSString *)title
                 imageName:(NSString *)imageName
                     index:(NSInteger)index{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 65, 75)];
    UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 45, 45)];
    iconImage.image = [UIImage imageNamed:imageName];
    [containerView addSubview:iconImage];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 55, 65, 20)];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:titleLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 75)];
    button.tag = index;
    [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:button];
    return containerView;
}



#pragma mark Action
//按钮事件
- (void)btnAction:(UIButton *)sender {
    switch (sender.tag) {
        case 0: //新号
            [self keyAuthBtnActionWithRecord:nil type:@"1"];
            break;
        case 1: //老号
            [self keyAuthBtnActionWithRecord:nil type:@"2"];
            break;
        case 2: //复扫
            [self repeatScanClicked];
            break;
        case 3: //显码
            [self showQRCodeAction];
            break;
        default:
            break;
    }
}

//一键授权
- (void)keyAuthBtnActionWithRecord:(NSDictionary *)record type:(NSString *)type {
    if (type.length <= 0) {
        type = @"1";
    }
    NSString *accountType = [[UserInfoModel shared] getAccountType];
    if (![[UserInfoModel shared] isLogin]) {
        [LoginVC showLoginVC:self];
        return;
    } else if (self.wxUrl == nil || [self.wxUrl isEqualToString:@""]) {
        [self alert:@"提示" message:@"未检测到需要授权的APP\n请打开需要授权的APP\n点击微信授权登录" cancelEnable:NO handler:nil cancelHandler:nil];
        return;
    } else if (!self.qrCodeContent || [self.qrCodeContent isEqualToString:@""]) {
        [self alert:@"提示" message:@"授权二维码获取中，请稍后" cancelEnable:NO handler:nil cancelHandler:nil];
        return;
    } else {
        self.authType = 2;
        NSString *url = [NSString stringWithFormat:@"%@/autoAuth", baseUrl];
        NSString *uuid = [self.qrCodeContent componentsSeparatedByString:@"uuid="].lastObject;
        NSDictionary *parameters;
        NSString *state = [self.requestParameter[@"state"] componentsSeparatedByString:@"&"].firstObject;
        if ([state isEqualToString:@""]) {
            state = @"w";
        }
        if (
//            [record[@"appId"] isEqualToString:self.appid]
            record[@"id"]
            ) {
            parameters = @{@"appId": self.appid,
                           @"qrCode": self.qrCodeContent,
                           @"uuid": uuid,
                           @"id": record[@"id"],
                           @"state": state,
                           @"type":type,
                           @"grade":accountType
            };
        } else {
            parameters = @{@"appId": self.appid,
                           @"qrCode": self.qrCodeContent,
                           @"uuid": uuid,
                           @"state": state,
                           @"type":type,
                           @"grade":accountType
            };
        }
        if (parameters[@"id"]) {
            [SVProgressHUD showWithStatus:@"复扫请求中\n请勿退出当前界面⚠️"];
        } else {
            [SVProgressHUD showWithStatus:@"授权请求中\n请勿退出当前界面⚠️"];
        }
        @weakify(self);
        [[NetworkingManager manager] postDataWithUrl:url parameters:parameters success:^(id json) {
            @strongify(self);
            NSDictionary *data = json[@"data"];
            self.startActionTimes = self.actionTimes;
            if (parameters[@"id"]) {
                self.authOrderId = record[@"id"];
            } else {
                self.authOrderId = [NSString nullToString:data[@"authOrderId"]];
            }
            [UserInfoModel requestInfo:nil];
            NSString *code = [NSString nullToString:data[@"code"]];
            if (code && ![code isEqualToString:@""] && [code hasPrefix:self.appid]) {
                NSString *hasPrefixCode = [code componentsSeparatedByString:@"&"].firstObject;
//                NSLog(@"hasPrefixCode:%@",hasPrefixCode);
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&state=%@", hasPrefixCode, [self.requestParameter[@"state"] componentsSeparatedByString:@"&"].firstObject]];
//                NSLog(@"URLWithString:%@",url);

                if (@available(iOS 10.0, *)) {
                    [[UIApplication  sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                        @strongify(self);
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                } else {
                    [[UIApplication sharedApplication] openURL:url];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        } failure:^(NSError *error) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            self.fd_interactivePopDisabled = YES;
            [SVProgressHUD dismiss];
            @strongify(self);
            if (error.code == 20006) {
                NSDictionary *param = @{
                    @"appid": self.appid,
                    @"bundleid": self.requestParameter[@"bundleid"],
                    @"scope": [NSString stringWithFormat:@"scope=%@&state=%@", self.requestParameter[@"scope"], self.requestParameter[@"state"]],
                    @"wxNickname": self.wxNickname,
                    @"imageUrl": self.authAvatar
                };
                [self showInputAlert:param];
            } else {
                [SVProgressHUD showErrorWithStatus:error.domain];
            }
        }];
    }
}

//显示二维码
- (void)showQRCodeAction {
    if (![[UserInfoModel shared] isLogin]) {
        [LoginVC showLoginVC:self];
        return;
    } else if (self.wxUrl == nil || [self.wxUrl isEqualToString:@""]) {
        [self alert:@"提示" message:@"未检测到需要授权的APP\n请打开需要授权的APP\n点击微信授权登录" cancelEnable:NO handler:nil cancelHandler:nil];
        return;
    } else {
        self.authType = 1;
        NSString *url = [NSString stringWithFormat:@"%@/QRCodeAuth", baseUrl];
        [SVProgressHUD showWithStatus:@"授权中，请耐心等待..."];
        @weakify(self);
        [[NetworkingManager manager] postDataWithUrl:url parameters:@{@"appId": self.appid} success:^(id json) {
            @strongify(self);
            [SVProgressHUD dismiss];
            NSString *authRecordId = (NSString *)json[@"data"];
            self.authOrderId = authRecordId;
            [UserInfoModel requestInfo:nil];
            //显示二维码
            [self showQRCodeImage: YES];
        } failure: nil];
    }
}

//显示二维码图片
- (void)showQRCodeImage:(BOOL)isUploadRecord {
    NSString *qrCodeBase64 = [self createQRCodeWithContent:self.qrCodeContent];
    qrCodeBase64 = [qrCodeBase64 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    qrCodeBase64 = [qrCodeBase64 stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    qrCodeBase64 = [qrCodeBase64 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *qrCodeData = [NSString stringWithFormat:@"data:image/png;base64,%@", qrCodeBase64];
    NSString *qrCodeHiddenJS = [NSString stringWithFormat:@"document.getElementsByClassName(\"auth_qrcode\")[0].src='%@'",qrCodeData];
    [self.webView stringByEvaluatingJavaScriptFromString: qrCodeHiddenJS];
    @weakify(self);
    dispatch_queue_after_S(1, ^{
        @strongify(self);
        UIImage *screenImage = [self screenShot];
        [LBXScanNative recognizeImage:screenImage success:^(NSArray<LBXScanResult *> *array) {
            @strongify(self);
            if (array && array.count > 0) {
                NSString *qrCodeContent = [NSString stringWithFormat:@"%@", array[0].strScanned];
                if ([qrCodeContent hasPrefix:@"https://open.weixin.qq.com/connect/confirm"]) {
                    self.qrCodeContent = qrCodeContent;
                    if (isUploadRecord) {
                        [self updateRecordWithAuthNo: self.authOrderId];
                    }
                } else {
                    [self showQRCodeImage:isUploadRecord];
                }
                return;
            } else {
                [self showQRCodeImage:isUploadRecord];
            }
        }];
    });
}

//生成二维码
- (NSString *)createQRCodeWithContent:(NSString *)content {
    UIImage *qrCodeImg;
    if (self.authAvatarImg) {
        qrCodeImg = [LBXScanNative createQRWithString:content QRSize:CGSizeMake(215, 215) icon:self.authAvatarImg];
    } else {
        qrCodeImg = [LBXScanNative createQRWithString:content QRSize:CGSizeMake(215, 215)];
    }
    NSString *imageData = [qrCodeImg encodeToBase64String];
    return imageData;
}

// 上传授权成功的记录
- (void)updateRecordWithAuthNo:(NSString *)authNo {
    NSString *url = [NSString stringWithFormat:@"%@/updateRecord", baseUrl];
    NSString *uuid = [self.qrCodeContent componentsSeparatedByString:@"uuid="].lastObject;
    NSDictionary *parameters;
    if (self.authType == 1) {
        parameters = @{@"authRecordId": authNo,
                       @"appId": self.appid,
                       @"platformName": self.wxNickname,
                       @"imageUrl": self.authAvatar,
                       @"uuid": uuid
        };
    } else {
        parameters = @{@"authRecordId": authNo,
                       @"appId": self.appid,
                       @"uuid": uuid
        };
    }
    [[NetworkingManager manager] postDataWithUrl:url parameters:parameters success:nil failure:nil];
}

// 售后申请
- (void)applyAfterSaleWithOrderId:(NSString *)orderId {
    NSString *url = [NSString stringWithFormat:@"%@/afterSale/%@", baseUrl, orderId];
    if (orderId) {
        [SVProgressHUD showErrorWithStatus:@"申请售后失败，请到授权记录，申请售后"];
        return;
    }
    @weakify(self);
    [[NetworkingManager manager]
     postDataWithUrl:url parameters:nil success:^(id json) {
        @strongify(self);
        [SVProgressHUD showSuccessWithStatus:@"申请售后成功，已退款"];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:nil];
}


- (void)alert:(NSString*)title message:(NSString*)message cancelEnable:(BOOL)cancelEnable handler:(void (^ __nullable)(UIAlertAction *action))handler cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:handler];
    [alertCtrl addAction:action];
    if (cancelEnable) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:cancelHandler];
        [alertCtrl addAction:cancel];
    }
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (void)showInputAlert:(NSDictionary *)model{
    @weakify(self);
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"该APP暂未收录，请输入APP名称，我们会尽快为您添加" preferredStyle:
                                  UIAlertControllerStyleAlert];
    // 添加输入框 (注意:在UIAlertControllerStyleActionSheet样式下是不能添加下面这行代码的)
    [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入APP名称";
        NSString *info = [NSString nullToString:model[@"info"]];
        textField.text = info;
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        // 通过数组拿到textTF的值
        NSString *platform = [[alertVc textFields] objectAtIndex:0].text;
        [self platformApplyRequest:model platform:platform];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    // 添加行为
    [alertVc addAction:action2];
    [alertVc addAction:action1];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)reloadClicked{
    [self.webView reload];
}

- (void)repeatScanClicked{
    if (![UserInfoModel shared].isLogin) {
        [LoginVC showLoginVC:self];
        return;
    }
    RepeatScanRecordVC *vc = [[RepeatScanRecordVC alloc] init];
    vc.appId = self.appid;
    vc.authType = 1;
    @weakify(self);
    vc.didSelectBlock = ^(NSDictionary *model) {
        @strongify(self);
        if (model) {
            [self keyAuthBtnActionWithRecord:model type:@""];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)platformApplyRequest:(NSDictionary *)model platform:(NSString *)platform {
    NSString *bundleid = model[@"bundleid"];
    if (bundleid == nil) {
        [SVProgressHUD showErrorWithStatus:@"未获取到包名，请检查系统版本是否小于13.0"];
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@/platformApply", baseUrl];
    NSDictionary *parameters = @{
        @"platformName": platform,
        @"appId": model[@"appid"],
        @"bundleId": bundleid,
        @"scope": model[@"scope"],
        @"nickname": model[@"wxNickname"],
        @"imageUrl": model[@"imageUrl"],
        @"device": @"1"
    };
    [SVProgressHUD show];
    [[NetworkingManager manager] postDataWithUrl:url parameters:parameters success:^(id json) {
        [SVProgressHUD showSuccessWithStatus:@"提交申请成功，请耐心等待客服审核"];
    } failure:nil];
}

-(UIBarButtonItem*)customBackBarItem{
    if (!_customBackBarItem) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"icon_nav_back"] style: UIBarButtonItemStylePlain target: self action:@selector(customBackItemClicked)];
        _customBackBarItem = item;
    }
    return _customBackBarItem;
}

-(void)customBackItemClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)updateNavigationItems {
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.navigationItem setLeftBarButtonItems:@[self.customBackBarItem]];
    if (![self.webView.request.URL.absoluteString hasPrefix: wx_base_url]) {
        [self.bottomContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(0.0);
        }];
        self.bottomContainerView.hidden = YES;
    } else {
        [self.bottomContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-40);
            make.height.mas_equalTo(75);
        }];
        self.bottomContainerView.hidden = NO;
    }
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    // 跳转到授权的APP
    NSURL *url = request.URL;
    if (!url) {
        return NO;
    }
    NSString *urlStr = url.absoluteString;
    NSString *scheme = url.scheme == nil ? @"":url.scheme;
    NSArray *schemes = @[@"https", @"http"];
    BOOL cancel = [urlStr containsString:@"://itunes.apple.com/"] || ![schemes containsObject:scheme];
    if (cancel) {
        if ([urlStr hasPrefix:self.appid]) {
            NSString *wxUserNickName = [[self.webView stringByEvaluatingJavaScriptFromString: @"document.body.innerText"] componentsSeparatedByString:@"授"][0];
            [self confirmOrderRequest:urlStr wxNickname:[wxUserNickName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            self.fd_interactivePopDisabled = YES;
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            [SVProgressHUD showSuccessWithStatus:@"授权成功，即将跳转"];
        }
        if (@available(iOS 10.0, *)) {
            [[UIApplication  sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                if ([webView canGoBack]) {
                    [webView goBack];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        } else {
            if ([webView canGoBack]) {
                [webView goBack];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
            [[UIApplication sharedApplication] openURL:url];
        }
        return NO;
    }
    return YES;
}

- (void)confirmOrderRequest:(NSString *)redirectUrl
                 wxNickname:(NSString *)wxNickname{
    if (!self.authOrderId || [self.authOrderId isEqualToString:@""]) {
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@/confirmOrder", baseUrl];
    @weakify(self);
    [[NetworkingManager manager]
     postDataWithUrl:url
     parameters:@{
         @"authOrderId": self.authOrderId,
         @"redirectUrl": redirectUrl,
         @"wxUserNickname": wxNickname
     } success:^(id json) {
        @strongify(self);
        self.fd_interactivePopDisabled = YES;
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    } failure: nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *qrCodeJS = @"document.getElementsByClassName(\"auth_qrcode\")[0].src";
    NSString *wxNicknameJS = @"document.getElementsByClassName(\"auth_nickname\")[0].textContent";
    NSString *authAvatarJS = @"document.getElementsByClassName(\"auth_avatar\")[0].src";
    //    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString * qrCodeHiddenJS = [NSString stringWithFormat:@"document.getElementsByClassName(\"auth_qrcode\")[0].src='%@'",[UserInfoModel qrCdoe]];
    self.qrCodeUrl = [webView stringByEvaluatingJavaScriptFromString: qrCodeJS];
    self.wxNickname = [webView stringByEvaluatingJavaScriptFromString: wxNicknameJS];
    self.authAvatar = [webView stringByEvaluatingJavaScriptFromString: authAvatarJS];
    [webView stringByEvaluatingJavaScriptFromString: qrCodeHiddenJS];
    if (self.currentRecord && self.wxNickname && [self.appid isEqualToString:self.currentRecord[@"appId"]]) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@(复扫)", self.wxNickname];
    } else {
        self.navigationItem.title = self.wxNickname;
    }
    //解析二维码地址
    NSString *origin = webView.request.URL.absoluteString;
    if ([origin hasPrefix:@"https://open.weixin.qq.com/connect/app/qrconnect"]) {
        NSString *uuid = [self.qrCodeUrl componentsSeparatedByString:@"/"].lastObject;
        self.qrCodeContent = [NSString stringWithFormat:@"https://open.weixin.qq.com/connect/confirm?uuid=%@", uuid];
    }
    [self downloadQRImageWithURL:self.authAvatar originURL:origin];
    [self updateNavigationItems];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    //    [SVProgressHUD showErrorWithStatus:@"加载失败，请重试"];
}

- (UIImage *)screenShot {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height), NO, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenShotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenShotImage;
}

- (void)downloadQRImageWithURL:(NSString *)url originURL:(NSString *)origin {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer new];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"zh-cn" forHTTPHeaderField:@"Accept-Language"];
    [manager.requestSerializer setValue:origin forHTTPHeaderField:@"Referer"];
    [manager.requestSerializer setValue:@"image/png,image/svg+xml,image/*;q=0.8,video/*;q=0.8,*/*;q=0.5" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_3_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/7.0.0(0x17000024) NetType/WIFI Language/zh_CN" forHTTPHeaderField:@"User-Agent"];
    @weakify(self);
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        if ([UIImage imageWithData:responseObject]) {
            self.requestNumber = 0;
            self.authAvatarImg = [UIImage imageWithData:responseObject];
        } else {
            if (self.requestNumber <= 10) {
                dispatch_queue_after_S(0.3, ^{
                    @strongify(self);
                    self.requestNumber += 1;
                    [self downloadQRImageWithURL:url originURL:origin];
                });
            }
        }
    } failure:nil];
}

- (void)dealloc
{
    self.fd_interactivePopDisabled = YES;
    [SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer cancel];
}

@end
