//
//  ScanQRVC.h
//  
//

#import <LBXScanViewController.h>


@interface ScanQRVC : LBXScanViewController

@property (nonatomic, strong) UILabel *topTitle;

@property (nonatomic, strong) NSDictionary *param;

@property (nonatomic, strong) NSDictionary *authRecord;


#pragma mark --增加拉近/远视频界面
@property (nonatomic, assign) BOOL isVideoZoom;

#pragma mark - 底部几个功能：开启闪光灯、相册、我的二维码
//底部显示的功能项
@property (nonatomic, strong) UIView *bottomItemsView;

@property (nonatomic, strong) NSString *authType; //1：一键授权  2：专属授权

@end
