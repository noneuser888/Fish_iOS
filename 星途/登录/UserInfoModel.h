//
//  UserInfoModel.h
//  星途
//
//  Created by  on 2020/2/27.
//  
//

#import <Foundation/Foundation.h>

CG_INLINE void dispatch_queue_after_S(CGFloat time ,dispatch_block_t _Nullable block) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

typedef void(^RequestCompleteBlock)(NSDictionary * _Nullable data);

NS_ASSUME_NONNULL_BEGIN

@interface UserInfoModel : NSObject

@property (nonatomic, strong) NSString *loginToken;

@property (nonatomic, strong) NSString *agencyId;

@property (nonatomic, strong) NSDictionary *userInfo;


+ (UserInfoModel *)shared;

- (BOOL)isLogin;

- (void)setLogin:(BOOL)login;

- (void)userLogout;

- (void)setAccountType:(NSString *)type;

- (NSString *)getAccountType;

//- (NSString *)loginAgencyId;

//- (void)setLoginAgencyId:(NSString *)loginAgencyId;

+ (void)requestInfo:(_Nullable RequestCompleteBlock)block;

+ (NSString *)qrCdoe;

+ (BOOL)checkHTTPEnable;

+ (BOOL)isHTTPS;

+ (NSString *)userLevel:(NSInteger)level;

@end

NS_ASSUME_NONNULL_END
