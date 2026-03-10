//
//  NSBundle+ChangeBundleId.h
//  星途
//
//  Created by  on 2020/2/27.
//  
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (ChangeBundleId)

/**
 修改包名

 @param bundleId 包名，nil为默认包名
 */
- (void)changeBundleIdentifier:(NSString *)bundleId;

- (NSString *)bundleIdentifier;

@end

NS_ASSUME_NONNULL_END
