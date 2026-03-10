//
//  AppDelegate.m
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "LoginVC.h"
#import "AdVC.h"
#import "AuthVC.h"
#import "AdManager.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <JSPatchPlatform/JSPatch.h>
#import <AppOrderFiles/AppOrderFiles.h>
#import "HomeVC.h"
#import "NavController.h"

@interface AppDelegate ()

@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier taskId;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
//    [self setupJSPatchFile];
    if (@available(iOS 13, *)) {
        
    } else {
        self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.window makeKeyAndVisible];
        [SVProgressHUD setContainerView:self.window];
        [SVProgressHUD setMinimumDismissTimeInterval: 1.5f];
        [SVProgressHUD setMaximumDismissTimeInterval: 1.5f];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        HomeVC *homeVC = [HomeVC shared];
        NavController *nav = [[NavController alloc] initWithRootViewController:homeVC];
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"LaunchAds"]) {
            NSArray *ads = [[NSUserDefaults standardUserDefaults] valueForKey:@"LaunchAds"];
            NSInteger tag = [[[NSUserDefaults standardUserDefaults] valueForKey:@"LaunchAds.Tag"] integerValue];
            NSDictionary *param = ads[tag];
            AdVC *adVC = [[AdVC alloc] initWithParameter:param];
            if (tag + 1 <= ads.count - 1) {
                tag += 1;
            } else {
                tag = 0;
            }
            [[NSUserDefaults standardUserDefaults] setInteger:tag forKey: @"LaunchAds.Tag"];
            self.window.rootViewController = adVC;
        } else {
            self.window.rootViewController = nav;//main;
        }
        self.window.rootViewController = nav;
    }
    [self checkAppUpdate];
    [[AdManager shareManager] checkLaunchAd];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //键盘配置
        [IQKeyboardManager sharedManager].enable = YES;
        [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES; //设置点击背景收回键盘
        [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 64;
        
        //自动工具条
        [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
        [IQKeyboardManager sharedManager].toolbarManageBehaviour = IQAutoToolbarByPosition;
        //    [[IQKeyboardManager sharedManager].toolbarPreviousNextAllowedClasses addObject:[UIScrollView class]];
        
        [IQKeyboardManager sharedManager].shouldShowToolbarPlaceholder = YES;
        [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    });
    [self setupUMC];
    AppOrderFiles(^(NSString *orderFilePath) {
        NSLog(@"OrderFilePath:%@", orderFilePath);
    });
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

//获取热更新文件
//- (void)setupJSPatchFile {
//    [JSPatch startWithAppKey:@"aa4f0fd9cfd6c977"];
//    [JSPatch setupRSAPublicKey:@"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4Xd5YyjvUyL4OJwRUNUMmO9Mu\nOJe1ifxdnwWI79K3mtekwDVNJmtQx62ZQrHCN67I2FFinxBYIaof/UCn5Y2Fn9IQ\nhs9eVcj42qs6U3c7AReiLZY9eWXckoa+F2SaEcnywdP0O+fst5mUOPRb2wqbPpzC\nOAF+P4fAQUWRWwlVkQIDAQAB\n-----END PUBLIC KEY-----"];
//#ifdef DEBUG
//    [JSPatch setupDevelopment];
//    [JSPatch showDebugView];
//#endif
//    [JSPatch sync];
//}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    @weakify(self);
    self.taskId = [application beginBackgroundTaskWithExpirationHandler:^{
        @                                                                                                                                                                                                                                                                               strongify(self);
        [self endTask];
    }];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(longTimeTask:) userInfo:nil repeats:YES];
    //开启用户权限，否则不会显示
    //    NSString * version = [UIDevice currentDevice].systemVersion;
    //        if ([version floatValue] >= 8.0) {
    //            UIUserNotificationSettings * set = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
    //            [[UIApplication sharedApplication] registerUserNotificationSettings:set];
    //            [[UIApplication sharedApplication] registerForRemoteNotifications];
    //        }
    //设置显示数字
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


#pragma mark - 停止timer
-(void)endTask
{
    if (_timer != nil||
        _timer.isValid )
    {
        [_timer invalidate];
        _timer = nil;
        //结束后台任务
        [[UIApplication sharedApplication] endBackgroundTask:_taskId];
        _taskId = UIBackgroundTaskInvalid;
        NSLog(@"停止计时");
    }
}

- (void)longTimeTask:(NSTimer *)timer
{
    NSTimeInterval time = [[UIApplication sharedApplication] backgroundTimeRemaining];
    NSLog(@"系统留给的我们的时间 = %.02f Seconds", time);
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self endTask];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didUpdateUserActivity:(NSUserActivity *)userActivity {
    
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler API_AVAILABLE(ios(8.0)) {
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        
    }
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSString *urlStr = url.absoluteString;
    //    [self alert:@"提示" message:[NSString stringWithFormat:@"授权路径1：%@  \n授权路径2：%@", urlStr, [url absoluteString]] handler:^(UIAlertAction *action) {
    //
    //    } cancel:nil];
    if ([urlStr hasPrefix:@"weixin"]) {
        NSArray *paramArr = [urlStr componentsSeparatedByString:@"/"];
        NSString *appid;
        if (paramArr.count >= 4) {
            appid = paramArr[3];
        } else {
            [SVProgressHUD showErrorWithStatus:@"微信ID解析失败"];
            return YES;
        }
        NSString *bundleid = options[UIApplicationOpenURLOptionsSourceApplicationKey];
        NSString *state;
        if (paramArr.count >= 6 && [paramArr[5] componentsSeparatedByString:@"state="].count >= 2) {
            state = [paramArr[5] componentsSeparatedByString:@"state="][1];
        } else {
            state = @"";
        }
        NSDictionary *param = @{@"appid": appid,
                                @"bundleid": bundleid,
                                @"scope": @"snsapi_userinfo",
                                @"state": state
        };
        UIViewController *rootVC = self.window.rootViewController;
        if ([rootVC isKindOfClass:[NavController class]]) {
            UIViewController *navRootVC = (NavController *)rootVC.childViewControllers.firstObject;
            UIViewController *lastVC = (NavController *)rootVC.childViewControllers.lastObject;
            if ([navRootVC isKindOfClass:[HomeVC class]]) {
                UIViewController *currentVC = [UIViewController getCurrentVC];
                if ([currentVC isEqual:lastVC]) {
                    if (![currentVC isKindOfClass: [AuthVC class]]) {
                        AuthVC *authVc = [AuthVC initWithParameter:param];
                        [lastVC.navigationController pushViewController:authVc animated:true];
                    } else {
                        [(AuthVC *)lastVC loadWithParameter: param];
                    }
                } else {
                    HomeVC *homeVC = [HomeVC shared];
                    NavController *nav = [[NavController alloc] initWithRootViewController:homeVC];
                    self.window.rootViewController = nav;//main;
                    AuthVC *authVc = [AuthVC initWithParameter:param];
                    [homeVC.navigationController pushViewController:authVc animated:true];
                }
            } else {
                HomeVC *homeVC = [HomeVC shared];
                NavController *nav = [[NavController alloc] initWithRootViewController:homeVC];
                self.window.rootViewController = nav;//main;
                AuthVC *authVc = [AuthVC initWithParameter:param];
                [homeVC.navigationController pushViewController:authVc animated:true];
            }
        } else {
            HomeVC *homeVC = [HomeVC shared];
            NavController *nav = [[NavController alloc] initWithRootViewController:homeVC];
            self.window.rootViewController = nav;//main;
            AuthVC *authVc = [AuthVC initWithParameter:param];
            [homeVC.navigationController pushViewController:authVc animated:true];
        }
    }
    return YES;
}

- (void)checkAppUpdate {
    NSString *url = [NSString stringWithFormat:@"%@/checkUpdate", baseUrl];
    [[NetworkingManager manager] getDataWithUrl:url parameters:nil success:^(id json) {
        NSDictionary *data = json[@"data"];
        NSInteger lastVersion = [data[@"lastVersion"] integerValue];
        NSString *forceUpdate = data[@"forceUpdate"];
        NSString *appUrl = data[@"appUrl"];
        if ([currentVersion integerValue] < lastVersion && [forceUpdate isEqualToString:@"1"]) {
            //强制更新
            [self alert:@"更新提示" message:@"检测到有新版本，请立即更新" handler:^(UIAlertAction *action) {
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString:appUrl]];
                exit(0);
            } cancel:nil];
        } else if ([currentVersion integerValue] < lastVersion && ![forceUpdate isEqualToString:@"1"]) {
            [self alert:@"更新提示" message:@"检测到有新版本，请及时更新" handler:^(UIAlertAction *action) {
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString:appUrl]];
            } cancel:^(UIAlertAction *action) {
                return;
            }];
        }
    } failure:nil];
}

- (void)alert:(NSString*) title
      message:(NSString*) message
      handler:(void (^ __nullable)(UIAlertAction *action))handler
       cancel:(void (^ __nullable)(UIAlertAction *action))cancel{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:handler];
    [alertCtrl addAction:action];
    if (cancel) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:cancel];
        [alertCtrl addAction:cancelAction];
    }
    UIViewController *rootVC = [[UIApplication sharedApplication] keyWindow].rootViewController;
    if ([rootVC isKindOfClass: [AdVC class]]) {
        ((AdVC *)rootVC).isSkipAd = NO;
    }
    [rootVC presentViewController:alertCtrl animated:YES completion:nil];
}

#pragma mark - 友盟统计
- (void)setupUMC {
    [UMConfigure initWithAppkey:@"5eb22bc5167eddebdf0006fd" channel:@"App Store"];
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    if (@available(iOS 13.0, *)) {
        return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    } else {
        return nil;
    }
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
}

@end
