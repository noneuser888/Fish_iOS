//
//  StoreService.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StoreService : NSObject

+ (StoreService *)shared;

- (void)setData:(id)value forKey:(NSString *)key;

- (nullable id)getData:(NSString *)key;

- (void)setString:(NSString *)value forKey:(NSString *)key;

- (nullable NSString *)getString:(NSString *)key;

- (void)setBool:(BOOL)value forKey:(NSString *)key;

- (BOOL)getBool:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
