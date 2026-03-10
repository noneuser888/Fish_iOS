//
//  ScanQRVC.m
//  星途
//
//  Created by  on 2020/2/26.
//  
//

#import "ScanQRVC.h"
#import "LBXScanVideoZoomView.h"
#import "LoginVC.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "RepeatScanRecordVC.h"

@interface ScanQRVC ()

@property (nonatomic, strong) LBXScanVideoZoomView *zoomView;

@property (nonatomic, strong) UIBarButtonItem *rightBarBtn;

//复扫
@property (nonatomic, strong) UIButton *repeatScanBtn;

//识别结果
@property (nonatomic, strong) NSString *scanResult;

//账号类型
@property (nonatomic, strong) NSString *accountType; //1.新号  2.老号

@end

@implementation ScanQRVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[StoreService shared] getString:@"Auth.AccounType"]) {
        self.accountType = [[StoreService shared] getString:@"Auth.AccounType"];
    } else {
        self.accountType = @"1";
    }
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor blackColor];
    self.title = self.param[@"nickname"];
    //设置扫码后需要扫码图像
    self.isNeedScanImage = YES;
    
    [LBXPermission authorizeWithType:LBXPermissionType_Camera completion:^(BOOL granted, BOOL firstTime) {
        if (!granted) {
            [LBXPermissionSetting showAlertToDislayPrivacySettingWithTitle:@"提示" msg:@"没有相机权限，是否前往设置" cancel:@"取消" setting:@"设置"];
        }
    }];
    
    self.rightBarBtn = [[UIBarButtonItem alloc] initWithTitle: [self.accountType isEqualToString:@"1"] ? @"新号":@"老号" style:(UIBarButtonItemStylePlain) target:self action:@selector(changeAuthType)];
    self.navigationItem.rightBarButtonItems = @[self.rightBarBtn];
}

- (void)repeatScanClicked{
    RepeatScanRecordVC *vc = [[RepeatScanRecordVC alloc] init];
    vc.appId = self.param[@"appId"];
    vc.authType = 2;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.authRecord) {
        [self drawBottomItems];
    }
    [self drawTitle];
    [self.view bringSubviewToFront:_topTitle];
    
    if ([self.authType isEqualToString:@"1"] && self.authRecord) {
        self.title = [NSString stringWithFormat:@"%@(复扫)", self.param[@"nickname"]];
    } else {
        self.title = self.param[@"nickname"];
    }
    
}

//绘制扫描区域
- (void)drawTitle
{
    if (!_topTitle)
    {
        self.topTitle = [[UILabel alloc]init];
        _topTitle.bounds = CGRectMake(0, 0, 145, 60);
        _topTitle.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, 50);
        
        //3.5inch iphone
        if ([UIScreen mainScreen].bounds.size.height <= 568 )
        {
            _topTitle.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, 38);
            _topTitle.font = [UIFont systemFontOfSize:14];
        }
        
        _topTitle.textAlignment = NSTextAlignmentCenter;
        _topTitle.numberOfLines = 0;
        _topTitle.text = @"将取景框对准二维码即可自动扫描";
        _topTitle.textColor = [UIColor whiteColor];
        [self.view addSubview:_topTitle];
    }
}

- (void)cameraInitOver
{
    if (self.isVideoZoom) {
        [self zoomView];
    }
}

//- (LBXScanVideoZoomView*)zoomView
//{
//    if (!_zoomView)
//    {
//
//        CGRect frame = self.view.frame;
//
//        int XRetangleLeft = self.style.xScanRetangleOffset;
//
//        CGSize sizeRetangle = CGSizeMake(frame.size.width - XRetangleLeft*2, frame.size.width - XRetangleLeft*2);
//
//        if (self.style.whRatio != 1)
//        {
//            CGFloat w = sizeRetangle.width;
//            CGFloat h = w / self.style.whRatio;
//
//            NSInteger hInt = (NSInteger)h;
//            h  = hInt;
//
//            sizeRetangle = CGSizeMake(w, h);
//        }
//
//        CGFloat videoMaxScale = [self.scanObj getVideoMaxScale];
//
//        //扫码区域Y轴最小坐标
//        CGFloat YMinRetangle = frame.size.height / 2.0 - sizeRetangle.height/2.0 - self.style.centerUpOffset;
//        CGFloat YMaxRetangle = YMinRetangle + sizeRetangle.height;
//
//        CGFloat zoomw = sizeRetangle.width + 40;
//        _zoomView = [[LBXScanVideoZoomView alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)-zoomw)/2, YMaxRetangle + 40, zoomw, 18)];
//
//        [_zoomView setMaximunValue:videoMaxScale/4];
//
//
//        __weak __typeof(self) weakSelf = self;
//        _zoomView.block= ^(float value)
//        {
//            [weakSelf.scanObj setVideoScale:value];
//        };
//        [self.view addSubview:_zoomView];
//
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)];
//        [self.view addGestureRecognizer:tap];
//    }
//
//    return _zoomView;
//
//}

//- (void)tap
//{
//    _zoomView.hidden = !_zoomView.hidden;
//}

- (void)drawBottomItems
{
    if (_bottomItemsView) {
        return;
    }
    
    self.bottomItemsView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame)-164,
                                                                   CGRectGetWidth(self.view.frame), 100)];
    _bottomItemsView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    [self.view addSubview:_bottomItemsView];
    
    self.repeatScanBtn = [[UIButton alloc] init];
    self.repeatScanBtn.bounds = CGRectMake(0, 0, 45, 70);
    self.repeatScanBtn.center = CGPointMake(CGRectGetWidth(_bottomItemsView.frame)/2, CGRectGetHeight(_bottomItemsView.frame)/2);
    [self.repeatScanBtn setImage:[UIImage imageNamed:@"fusao_qr"] forState:UIControlStateNormal];
    [self.repeatScanBtn addTarget:self action:@selector(repeatScanClicked) forControlEvents:UIControlEventTouchUpInside];
    [_bottomItemsView addSubview:self.repeatScanBtn];
    
}

- (void)showError:(NSString*)str
{
    //    [LBXAlertAction showAlertWithTitle:@"提示" msg:str buttonsStatement:@[@"知道了"] chooseBlock:nil];
    [self alert:@"提示" message:str handler:nil cancel:nil];
}

- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    if (array.count < 1)
    {
        [self alert:@"提示" message:@"识别失败" handler:nil cancel:nil];
        //        [self popAlertMsgWithScanResult:nil];
        
        return;
    }
    
    //经测试，可以同时识别2个二维码，不能同时识别二维码和条形码
    for (LBXScanResult *result in array) {
        
        NSLog(@"scanResult:%@",result.strScanned);
    }
    
    LBXScanResult *scanResult = array[0];
    
    NSString*strResult = scanResult.strScanned;
    
    self.scanImage = scanResult.imgScanned;
    @weakify(self);
    if (!strResult) {
        [self alert:@"提示" message:@"识别失败" handler:nil cancel:nil];
        return;
    } else {
        if (![strResult hasPrefix:@"https://open.weixin.qq"]) {
            
            [self alert:@"提示" message:[NSString stringWithFormat:@"扫描结果\n%@", strResult] handler:^(UIAlertAction *action) {
                @strongify(self);
                [self reStartDevice];
            } cancel:nil];
        } else {
            if ([self.scanResult isEqualToString:strResult]) {
                [self alert:@"提示" message:@"二维码已授权" handler:^(UIAlertAction *action) {
                    @strongify(self);
                    [self reStartDevice];
                } cancel:nil];
            } else {
                self.scanResult = strResult;
                [self keyAuthRequest:strResult];
            }
        }
    }
    
    //震动提醒
    //     [LBXScanWrapper systemVibrate];
    //声音提醒
    //    [LBXScanWrapper systemSound];
    
    
}

- (void)alert:(NSString*) title message:(NSString*) message handler:(void (^ __nullable)(UIAlertAction *action))handler cancel:(NSString *)cancel {
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:handler];
    [alertCtrl addAction:action];
    if (cancel) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertCtrl addAction:cancelAction];
    }
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (void)keyAuthRequest:(NSString *)qrCodeUrl {
    if (![[UserInfoModel shared] isLogin]) {
        [LoginVC showLoginVC:self];
    } else {
        NSString *uuid = [qrCodeUrl componentsSeparatedByString:@"uuid="].lastObject;
        NSDictionary *parameters;
        
        NSString *level = [[UserInfoModel shared] getAccountType];

        if (self.authRecord && self.authRecord[@"id"]
//            && [self.authRecord[@"appId"] isEqualToString:self.param[@"appId"]]
            ) {
            parameters = @{@"appId": self.param[@"appId"],
                           @"qrCode": qrCodeUrl,
                           @"uuid": uuid,
                           @"id": self.authRecord[@"id"],
                           @"type":self.accountType,
													 @"grade": level,
            };
        } else {
            parameters = @{@"appId": self.param[@"appId"],
                           @"qrCode": qrCodeUrl,
                           @"uuid": uuid,
                           @"type":self.accountType,
													 @"grade": level,
            };
        }
        NSString *url;
        NSString *accountTypeStr = [self.accountType isEqualToString:@"1"] ? @"(新号)":@"(新号)";
        if ([self.authType isEqualToString:@"1"]) {
            url = [NSString stringWithFormat:@"%@/autoAuth", baseUrl];
            if (parameters[@"id"]) {
                [SVProgressHUD showWithStatus:@"复扫请求中"];
            } else {
                [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"授权请求中%@", accountTypeStr]];
            }
        } else {
            url = [NSString stringWithFormat:@"%@/exclusiveAuth", baseUrl];
            [SVProgressHUD showWithStatus:@"授权请求中"];
        }
        @weakify(self);
        [[NetworkingManager manager] postDataWithUrl:url parameters:parameters success:^(id json) {
            @strongify(self);
            if (parameters[@"id"]) {
                [self confirmOrderRequest:self.authRecord[@"id"]];
            } else {
                NSDictionary *data = json[@"data"];
                NSString *authOrderId = [NSString nullToString:data[@"authOrderId"]];
                if (authOrderId && ![authOrderId isEqualToString:@""]) {
                    [self confirmOrderRequest:authOrderId];
                }
            }
            [UserInfoModel requestInfo:nil];
            [SVProgressHUD showSuccessWithStatus:@"扫码授权成功，请耐心等待"];
            if (self.authRecord) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self performSelector:@selector(reStartDevice) withObject:nil afterDelay:1.5];
            }
        } failure:nil];
    }
}

- (void)confirmOrderRequest:(NSString *)authOrderId {
    NSString *url = [NSString stringWithFormat:@"%@/confirmOrder", baseUrl];
    @weakify(self);
    [[NetworkingManager manager] postDataWithUrl:url parameters:@{@"authOrderId": authOrderId} success:^(id json) {
        @strongify(self);
        self.fd_interactivePopDisabled = YES;
        if (self.authRecord) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    } failure: nil];
}

- (void)changeAuthType {
    if ([self.accountType isEqualToString:@"1"]) {
        self.accountType = @"2";
    } else {
        self.accountType = @"1";
    }
    [[StoreService shared] setString:self.accountType forKey:@"Auth.AccounType"];
    [self.rightBarBtn setTitle:[self.accountType isEqualToString:@"1"] ? @"新号":@"老号"];
}

@end
