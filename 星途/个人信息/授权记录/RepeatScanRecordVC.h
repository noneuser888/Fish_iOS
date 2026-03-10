//
//  RepeatScanRecordVC.h
//  星途
//
//  Created by  on 2020/4/21.
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RepeatScanRecordVC : UIViewController

@property (nonatomic, strong) NSString *appId;

@property (nonatomic, assign) NSInteger authType; //授权类型：1.一键授权  2：扫码授权

@property (nonatomic, strong) void(^didSelectBlock)(NSDictionary *);

+ (NSDictionary *)currentAuthRecord;

@end

NS_ASSUME_NONNULL_END
