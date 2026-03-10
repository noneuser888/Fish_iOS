//
//  UIViewController+Return.m
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation UIViewController (Return)

+ (void) load {
    Method originalMethod = class_getInstanceMethod(self, @selector(viewDidLoad));
    Method swizzledMethod = class_getInstanceMethod(self, @selector(viewDidLoadReturnHook));
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
    originalMethod = class_getInstanceMethod(self, @selector(viewDidAppear:));
    swizzledMethod = class_getInstanceMethod(self, @selector(viewDidAppearStatsHook:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
    originalMethod = class_getInstanceMethod(self, @selector(viewDidDisappear:));
    swizzledMethod = class_getInstanceMethod(self, @selector(viewDidDisappearStatsHook:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void) viewDidLoadReturnHook {
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    [self viewDidLoadReturnHook];
    
    if (self.navigationItem.hidesBackButton) {
        // 如果用户手动设置隐藏返回按钮，则不添加 leftBarButtonItem
        return;
    }
    
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = [self app_buttonWithBack];
    }
    
//    self.navigationController.navigationBar.translucent = NO;
//    [self.navigationController.navigationBar setTitleTextAttributes:@{[NSForegroundColorAttributeName: [UIColor whiteColor]]}];
    UIColor *bgColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"#333333"];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBarTintColor:bgColor];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
}

- (void)viewDidAppearStatsHook:(BOOL)animated {
    [self viewDidAppearStatsHook:animated];
    
    NSString *class = NSStringFromClass([self class]);
    
#if DEBUG
    NSLog(@"viewDidAppear: %@", class);
#endif
}

- (void)viewDidDisappearStatsHook:(BOOL)animated {
    [self viewDidDisappearStatsHook:animated];
    
    NSString *class = NSStringFromClass([self class]);
}

- (UIBarButtonItem *)app_buttonWithBack{
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_nav_back"]
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(app_backToParent)];
}

- (void)app_backToParent{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
