//
//  AdVC.m
//
//  Created by  on 2020/2/25.
//  
//

#import "AdVC.h"
#import "NavController.h"
#import "HomeVC.h"

@interface AdVC ()

@property (nonatomic, strong)UIImageView *adImageView;

@property (nonatomic, strong)NSDictionary *param;

@property (nonatomic, assign)BOOL isHidden;

@property (nonatomic, strong)NSArray *dataSource;

@end

@implementation AdVC

- (AdVC *)initWithParameter:(NSDictionary *)parameter {
    AdVC *adVC = [[AdVC alloc] init];
    adVC.param = parameter;
    return adVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isSkipAd = YES;
    self.isHidden = NO;
    self.dataSource = [[NSArray alloc] init];
    self.adImageView = [[UIImageView alloc] init];
    [self.view addSubview:self.adImageView];
    [self.adImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    UIButton *skipAdBtn = [[UIButton alloc] init];
    [skipAdBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [skipAdBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [skipAdBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    skipAdBtn.backgroundColor = [UIColor colorWithRed:0.0/255 green:0.0/255 blue:0.0/255 alpha:0.55];
    skipAdBtn.layer.cornerRadius = 3.0;
    skipAdBtn.layer.borderColor = [UIColor.whiteColor CGColor];
    skipAdBtn.layer.borderWidth = 1.0;
    [skipAdBtn addTarget:self action:@selector(skipAd) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview:skipAdBtn];
    [skipAdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(34);
        make.right.equalTo(self.view).offset(-15);
        make.width.mas_equalTo(45);
        make.height.mas_equalTo(25);
    }];
    @weakify(self);
    NSString *imageUrl = self.param[@"imgUrl"];
    
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:imageUrl]];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:key];
    self.adImageView.image = image;
    
    // 自动隐藏广告
    dispatch_queue_after_S(4, ^{
        @strongify(self);
        if (self.isSkipAd) {
            [self skipAd];
        } else {
            return;
        }
    });
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAd:)];
    self.adImageView.userInteractionEnabled = YES;
    [self.adImageView addGestureRecognizer:gesture];
    
}

//展示广告
- (void)showAd:(UIGestureRecognizer *)gesture {
    NSString *webLink = self.param[@"webLink"];
    if (webLink && webLink.length > 0) {
        self.isHidden = YES;
        HomeVC *homeVC = [HomeVC shared];
        NavController *nav = [[NavController alloc] initWithRootViewController:homeVC];
        [[UIApplication sharedApplication] keyWindow].rootViewController = nav;
        dispatch_queue_after_S(0.3, ^{
            WKWebViewController *wkWebVC = [[WKWebViewController alloc] init];
            [wkWebVC loadWithURLString:webLink];
            [homeVC.navigationController pushViewController:wkWebVC animated: YES];
        });
    } else {
        return;
    }
}

// 隐藏广告
- (void)skipAd {
    if (self.isHidden) {
        return;
    }
    self.isHidden = YES;
    NavController *nav = [[NavController alloc] initWithRootViewController:[HomeVC shared]];
    [[UIApplication sharedApplication] keyWindow].rootViewController = nav;
}

- (UIImage *)getLaunchImage {
    // 获取Assets.xcassets中launchImage
    CGSize viewSize = [[UIApplication sharedApplication] keyWindow].frame.size;
    NSString *viewOrientation = @"Portrait"; //横屏请设置成 @”Landscape”
    NSString *launchImage = nil;
    // build后app包里面有一个info.plist，其中有个UIlaunchImages的array
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    return [UIImage imageNamed:launchImage];
}

@end

