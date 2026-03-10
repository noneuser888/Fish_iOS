//
//  NSDate+App.h
//  星途
//
//  Created by  on 2020/3/24.
//  
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (App)

///系统当前运行了多长时间
+ (NSTimeInterval)uptimeSinceLastBoot;

@end

NS_ASSUME_NONNULL_END
