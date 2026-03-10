//
//  WKWebViewController.m
//  星途
//
//  Created by  on 2020/3/14.
//  
//

#import "WKWebViewController.h"

@interface WKWebViewController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (strong, nonatomic, readwrite) WKWebView *webView;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, copy) NSString *urlString;

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *customUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148";
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"User-Agent": customUserAgent, @"UserAgent": customUserAgent}];
    WKPreferences *preference = [[WKPreferences alloc]init];
    preference.minimumFontSize = 0;
    preference.javaScriptEnabled = YES;
    preference.javaScriptCanOpenWindowsAutomatically=YES;
    WKUserContentController *wkuserCVC = [[WKUserContentController alloc]init];
    WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    config.processPool = [[WKProcessPool alloc]init];
    config.preferences = preference;
    config.userContentController = wkuserCVC;
    if ([config respondsToSelector:@selector(websiteDataStore)]) {
        config.websiteDataStore = dataStore;
    }
    config.suppressesIncrementalRendering = NO;
    if ([config respondsToSelector:@selector(applicationNameForUserAgent)]) {
        config.applicationNameForUserAgent = @"user-agent";//iOS9
    }
    if ([config respondsToSelector:@selector(allowsAirPlayForMediaPlayback)]) {
        config.allowsAirPlayForMediaPlayback =YES;//airplay isallowed //iOS9
    }
    config.allowsInlineMediaPlayback = YES;
    config.selectionGranularity = WKSelectionGranularityDynamic;
    if ([config respondsToSelector:@selector(allowsPictureInPictureMediaPlayback)]) {
        config.allowsPictureInPictureMediaPlayback = YES; //iOS9
    }
    //允许自动播放视频 音频
    if ([config respondsToSelector:@selector(mediaTypesRequiringUserActionForPlayback)]) {
        if (@available(iOS 10.0, *)) {
            config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
        } else {
            // Fallback on earlier versions
        }//ios10
    }else if ([config respondsToSelector:@selector(requiresUserActionForMediaPlayback)]) {
        config.requiresUserActionForMediaPlayback = false;
    }
    
    if ([config respondsToSelector:@selector(dataDetectorTypes)]) {
        if (@available(iOS 10.0, *)) {
            config.dataDetectorTypes = UIDataDetectorTypePhoneNumber;
        } else {
            // Fallback on earlier versions
        }
    }
    if ([config respondsToSelector:@selector(ignoresViewportScaleLimits)]) {
        if (@available(iOS 10.0, *)) {
            config.ignoresViewportScaleLimits = NO;
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    _webView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:config];
    
    [_webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString *userAgent, NSError * _Nullable error) {
        if ([userAgent hasSuffix:@"MicroMessenger/7.0.0(0x17000024) NetType/WIFI Language/zh_CN"]) {
            NSRange r1 = [userAgent rangeOfString:@" MicroMessenger/7.0.0(0x17000024) NetType/WIFI Language/zh_CN"];
            NSString *customUserAgent = [userAgent substringToIndex:r1.location];
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"User-Agent": customUserAgent, @"UserAgent": customUserAgent}];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
    //    [self.webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    
    _webView.allowsBackForwardNavigationGestures = YES;
    
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    //监听web内容加载进度、是否加载完成
    [_webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:nil];
    if (self.useWebPageTitle) {
        [_webView addObserver:self forKeyPath:NSStringFromSelector(@selector(title)) options:NSKeyValueObservingOptionNew context:nil];
    }
    
    if (self.urlString.length > 0) {
        [self loadWithURLString:self.urlString];
    }
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (_activityIndicatorView == nil) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.backgroundColor = [UIColor colorWithHexString:@"#F8F8F8"];
        _activityIndicatorView.layer.cornerRadius = 5;
        [self.view addSubview:_activityIndicatorView];
        [_activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.width.height.mas_equalTo(60);
        }];
    }
    return _activityIndicatorView;
}

- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    if (self.useWebPageTitle) {
        [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(title))];
    }
}

#pragma mark - public func
- (void)loadWithURLString:(NSString *)urlString{
    if (self.webView == nil) {
        self.urlString = urlString;
    }else{
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    id new = change[NSKeyValueChangeNewKey];
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(title))]) {
        self.title = new;
    }else if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]) {
        double estimatedProgress = [new doubleValue];
        if (estimatedProgress >= 1) {
            if (self.loadCompleteBlock) {
                self.loadCompleteBlock();
            }
            [self.activityIndicatorView stopAnimating];
        } else {
            [self.activityIndicatorView startAnimating];
        }
    }
}


#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    return webView;
}

- (void)webViewDidClose:(WKWebView *)webView{
    
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    
}

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo API_AVAILABLE(ios(10.0)){
    return YES;
}

- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions API_AVAILABLE(ios(10.0)){
    return self;
}

- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController{
    
}

- (void)webView:(WKWebView *)webView runOpenPanelWithParameters:(WKOpenPanelParameters *)parameters initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSArray<NSURL *> * _Nullable URLs))completionHandler{
    
}

#pragma mark - WKNavigationDelegate
//加载步骤0
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    //如果是跳转一个新页面
    //    if (navigationAction.targetFrame == nil)
    //    {
    //        [webView loadRequest:navigationAction.request];
    //    }
    //    decisionHandler(WKNavigationActionPolicyAllow);
    NSURL *url = navigationAction.request.URL;
    if (url == nil) {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    NSString *urlString = url.absoluteString;
    NSArray *schemes = @[@"https", @"http", @"about"];
    NSString *scheme = url.scheme;
    BOOL cancel = ([urlString containsString:@"://itunes.apple.com/"] || ![schemes containsObject:scheme]);
    if (cancel) {
        decisionHandler(WKNavigationActionPolicyCancel);
        if (@available(iOS 10.0, *)) {
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler: nil];
            } else {
                [SVProgressHUD showErrorWithStatus:@"未安装该应用"];
            }
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

//加载步骤1
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
    NSLog(@"加载步骤1");
}

//加载步骤2
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    decisionHandler(WKNavigationResponsePolicyAllow);
    
    NSLog(@"加载步骤2");
}

//加载步骤3
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    
    NSLog(@"加载步骤3");
}

//加载步骤4
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    self.title = self.webView.title;
    NSLog(@"加载步骤4");
}

//加载步骤5
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    
    completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
    NSLog(@"加载步骤5");
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}

//请求错误
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
}



- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
}



- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    NSLog(@"%@",message);
    NSLog(@"%@",message.body);
    NSLog(@"%@",message.name);
}

@end
