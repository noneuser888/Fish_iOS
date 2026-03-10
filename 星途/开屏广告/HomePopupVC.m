//
//  HomePopupVC.m
//  星途
//
//  Created by  on 2020/5/11.
//  
//

#import "HomePopupVC.h"
#import "NavController.h"
#import <SafariServices/SafariServices.h>


// 请求回调
typedef void(^Callback)(CGSize size);

@interface HomePopupVC ()

@end

@implementation HomePopupVC

+ (HomePopupVC *)vc {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HomePopupVC" bundle:nil];
    HomePopupVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"HomePopupVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    if (!self.params) {
        return;
    }
    NSString *imageUrl = self.params[@"imgUrl"];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetail)];
    [imageView addGestureRecognizer:tap];
    [self.view addSubview:imageView];
    
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn setImage:[UIImage imageNamed:@"popup_ic_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(hideAdView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    @weakify(self);
    [self getImageSizeWithURL:imageUrl callback:^(CGSize size) {
        @strongify(self);
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat height = screenSize.width * 0.7 * (size.height / size.width);
        CGFloat topConstraint = (screenSize.height - height - 25 - 80) / 2.0;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(topConstraint);
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.width.mas_equalTo(screenSize.width * 0.7);
            make.height.mas_equalTo(height);
        }];
        [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.top.mas_equalTo(imageView.mas_bottom).offset(20);
        }];
    }];
}

- (void)showDetail {
    NSString *webLink = [NSString nullToString:self.params[@"webLink"]];
    if (webLink && ![webLink isEqualToString:@""]) {
        if ([webLink hasPrefix:@"http"] && ![webLink containsString:@"://itunes.apple.com/"]) {
            WKWebViewController *wkVC = [[WKWebViewController alloc] init];
            [wkVC loadWithURLString:webLink];
            [self.navigationController pushViewController:wkVC animated:true];
        } else {
            if (@available(iOS 10.0, *)) {
                [[UIApplication  sharedApplication] openURL:[NSURL URLWithString:webLink] options:@{} completionHandler: nil];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:webLink]];
            }
        }
    } else {
        return;
    }
}

- (void)hideAdView {
    [self dismissViewControllerAnimated:NO completion:nil];
}

/**
 *  根据图片url获取图片尺寸
 */
- (void)getImageSizeWithURL:(id)URL callback:(Callback)callback{
    NSURL * url = nil;
    if ([URL isKindOfClass:[NSURL class]]) {
        url = URL;
    }
    if ([URL isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:URL];
    }
    if (!URL) {
        if (callback) {
            callback(CGSizeZero);
        }
    }
    CGImageSourceRef imageSourceRef =     CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    CGFloat width = 0, height = 0;
    if (imageSourceRef) {
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL);
        if (imageProperties != NULL) {
            CFNumberRef widthNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
            
            //            if (widthNumberRef != NULL) {
            //                CFNumberGetValue(widthNumberRef, kCFNumberFloat64Type, &width);
            //            }
            //            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            //            if (heightNumberRef != NULL) {
            //                CFNumberGetValue(heightNumberRef, kCFNumberFloat64Type, &height);
            //            }
            //判断设备是否为64位
#if defined(__LP64__) && __LP64__
            if (widthNumberRef != NULL) {
                CFNumberGetValue(widthNumberRef, kCFNumberFloat64Type, &width);
            }
            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            if (heightNumberRef != NULL) {
                CFNumberGetValue(heightNumberRef, kCFNumberFloat64Type, &height);
            }
#else
            if (widthNumberRef != NULL) {
                CFNumberGetValue(widthNumberRef, kCFNumberFloat32Type, &width);
            }
            CFNumberRef heightNumberRef = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
            if (heightNumberRef != NULL) {
                CFNumberGetValue(heightNumberRef, kCFNumberFloat32Type, &height);
            }
#endif
            
            CFRelease(imageProperties);
        }
        CFRelease(imageSourceRef);
    }
    if (callback) {
        callback(CGSizeMake(width, height));
    }
}


@end
