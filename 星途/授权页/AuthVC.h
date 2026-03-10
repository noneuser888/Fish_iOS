//
//  AuthVC.h
//  星途
//
//  Created by  on 2020/2/25.
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AuthVC : UIViewController

+ (instancetype)initWithURL:(nullable NSString *)url;

+ (instancetype)initWithParameter:(NSDictionary *)parameter;

- (void)loadWithURL:(NSString *)url;

- (void)loadWithParameter:(NSDictionary *)parameter;

//+ (BOOL)isShowQRCode;

@end

NS_ASSUME_NONNULL_END
