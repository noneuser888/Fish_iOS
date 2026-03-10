//
//  AdManager.h
//  星途
//
//  Created by  on 2020/2/26.
//  
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdManager : NSObject

+ (AdManager *)shareManager;

- (void)checkLaunchAd;

@end

NS_ASSUME_NONNULL_END
