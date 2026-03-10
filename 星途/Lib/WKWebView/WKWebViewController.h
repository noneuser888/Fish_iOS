//
//  WKWebViewController.h
//  星途
//
//  Created by  on 2020/3/14.
//  
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface WKWebViewController : UIViewController


@property (nonatomic, copy) void (^loadCompleteBlock)(void);

@property(nonatomic, copy) NSString *loadingText;

@property (strong, nonatomic, readonly) WKWebView *webView;
//vc使用网页标题 default:NO
@property (nonatomic, assign) BOOL useWebPageTitle;

- (void)loadWithURLString:(NSString *)urlString;

@end

