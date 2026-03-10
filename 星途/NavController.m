//
//  NavController.m
//  星途
//
//  Created by  on 2020/3/16.
//  
//

#import "NavController.h"

@interface NavController ()

@end

@implementation NavController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.tintColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.automaticallyAdjustsScrollViewInsets = NO;
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
//        [viewController setHidesBottomBarWhenPushed:YES];
    }
    [super pushViewController:viewController animated:animated];
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    UIViewController *topVC = self.topViewController;
//    return [topVC preferredStatusBarStyle];
//}

@end
