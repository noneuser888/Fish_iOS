//
//  UIViewController+App.m
//  星途
//
//  Created by  on 2020/3/14.
//  
//

#import "UIViewController+App.h"

@implementation UIViewController (App)

/** 递归查找当前显示的VC*/

+ (UIViewController *)recursiveFindCurrentShowViewControllerFromViewController:(UIViewController *)fromVC

{

    if ([fromVC isKindOfClass:[UINavigationController class]]) {

        return [self recursiveFindCurrentShowViewControllerFromViewController:[((UINavigationController *)fromVC) visibleViewController]];

    } else if ([fromVC isKindOfClass:[UITabBarController class]]) {

        return [self recursiveFindCurrentShowViewControllerFromViewController:[((UITabBarController *)fromVC) selectedViewController]];

    } else {

        if (fromVC.presentedViewController) {

            return [self recursiveFindCurrentShowViewControllerFromViewController:fromVC.presentedViewController];

        } else {

            return fromVC;

        }

    }

}

 

/** 查找当前显示的ViewController*/

+ (UIViewController *)getCurrentVC

{

    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;

    UIViewController *currentShowVC = [self recursiveFindCurrentShowViewControllerFromViewController:rootVC];

    return currentShowVC;

}

@end
