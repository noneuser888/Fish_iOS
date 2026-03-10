//
//  StoreService.m
//

#import "StoreService.h"

static StoreService *shared = nil;

@implementation StoreService

+ (StoreService *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[StoreService alloc] init];
    });
    return shared;
}

- (void)setData:(id)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:value forKey:key];
    [userDefaults synchronize];
}

- (nullable id)getData:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id value = [userDefaults valueForKey:key];
    return value;
}

- (void)setString:(NSString *)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:value forKey:key];
    [userDefaults synchronize];
}

- (nullable NSString *)getString:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults stringForKey:key];
    return value;
}

- (void)setBool:(BOOL)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:key];
    [userDefaults synchronize];
}

- (BOOL)getBool:(NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL value = [userDefaults boolForKey:key];
    return value;
}

@end
