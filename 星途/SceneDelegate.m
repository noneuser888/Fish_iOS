#import "SceneDelegate.h"
#import "AuthVC.h"
#import "AdVC.h"
#import "NavController.h"
#import "HomeVC.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions  API_AVAILABLE(ios(13.0)) API_AVAILABLE(ios(13.0)) API_AVAILABLE(ios(13.0)){
    UIOpenURLContext *context = [[connectionOptions.URLContexts objectEnumerator] nextObject];
    NSString *urlStr = context.URL.absoluteString;
    if ([scene isKindOfClass:[UIWindowScene class]]) {
        self.window = [[UIWindow alloc] initWithWindowScene: (UIWindowScene *)scene];
        [SVProgressHUD setContainerView:self.window];
        [SVProgressHUD setMinimumDismissTimeInterval: 3.0f];
        [SVProgressHUD setMaximumDismissTimeInterval:4.0f];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
        HomeVC *homeVC = [HomeVC shared];
        NavController *nav = [[NavController alloc] initWithRootViewController:homeVC];
        [self.window makeKeyAndVisible];
        if ([urlStr hasPrefix:@"weixin"]) {
            self.window.rootViewController = nav;
            [self dealUrl:urlStr context:context];
        } else {
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
                self.window.rootViewController = nav;
            }
        }
    }
}

- (void)sceneDidDisconnect:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
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

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts  API_AVAILABLE(ios(13.0)){
    NSEnumerator *enumerator = [URLContexts objectEnumerator];
    UIOpenURLContext *context;
    while (context = [enumerator nextObject]) {
        NSString *urlStr = context.URL.absoluteString;
        //        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"授权路径1：%@ \n授权路径2：%@", urlStr, [context.URL absoluteString]]];
        if ([urlStr hasPrefix:@"weixin"]) {
            NSArray *paramArr = [urlStr componentsSeparatedByString:@"/"];
            NSString *appid;
            if (paramArr.count >= 4) {
                appid = paramArr[3];
            }
            NSString *bundleid = bundleid = context.options.sourceApplication;
            NSArray *paramArr2 = [paramArr[5] componentsSeparatedByString:@"&"];
            NSString *state = [paramArr2[1] componentsSeparatedByString:@"state="][1];
            if (paramArr2.count >= 2 &&  [paramArr2[1] componentsSeparatedByString:@"state="].count >= 2) {
                state = [paramArr2[1] componentsSeparatedByString:@"state="][1];
            } else {
                state = @"";
            }
            if (paramArr2.count > 3) {
                bundleid = [paramArr2[2] componentsSeparatedByString:@"wechat_app_bundleId="][1];
            }
            if (!bundleid) {
                bundleid = @"null";
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
            break;
        }
        //        NSLog(@"context.URL =====%@",context.URL);
        //        NSLog(@"context.options.sourceApplication ===== %@",context.options.sourceApplication);
    }
    
    
}

- (void)dealUrl:(NSString *)urlStr context:(UIOpenURLContext *)context  API_AVAILABLE(ios(13.0)){
    if ([urlStr hasPrefix:@"weixin"]) {
        NSArray *paramArr = [urlStr componentsSeparatedByString:@"/"];
        NSString *appid = paramArr[3];
        NSString *bundleid = bundleid = context.options.sourceApplication;
        NSArray *paramArr2 = [paramArr[5] componentsSeparatedByString:@"&"];
        NSString *state = [paramArr2[1] componentsSeparatedByString:@"state="][1];
        if (paramArr2.count > 3) {
            bundleid = [paramArr2[2] componentsSeparatedByString:@"wechat_app_bundleId="][1];
        }
        if (!bundleid) {
            bundleid = @"null";
        }
        NSDictionary *param = @{@"appid": appid,
                                @"bundleid": bundleid,
                                @"scope": @"snsapi_userinfo",
                                @"state": state
        };
        UIViewController *vc = [UIViewController getCurrentVC];
        if (![vc isKindOfClass: [AuthVC class]]) {
            AuthVC *authVc = [AuthVC initWithParameter:param];
            [vc.navigationController pushViewController:authVc animated:true];
        } else {
            [(AuthVC *)vc loadWithParameter: param];
        }
    }
}


@end
