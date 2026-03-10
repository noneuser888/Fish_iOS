//
//  NSString+App.h
//  星途
//
//  Created by  on 2020/3/14.
//  
//


#import <Foundation/Foundation.h>

typedef enum: NSUInteger {
    DateFormatterTypeSecond = 1,
    DateFormatterTypeMinute,
    DateFormatterTypeMinute2,
    DateFormatterTypeDay,
    DateFormatterTypeMonth,
} DateFormatterType;

@interface NSString (App)

/**
*  将时间戳转换为可读的友好的方式显示
*/
+ (NSString *)coverDataTimeToHunmanTime:(NSString *)timeStr;

//格式化时间
+ (NSString *)stringWithDate:(NSDate *)date dateFormatterType:(DateFormatterType)type;

+ (NSString *)nullToString:(id)string;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSArray *)arrayWithJsonString:(NSString *)jsonString;

//校验身份证号
+ (BOOL)cly_verifyIDCardString:(NSString *)idCardString;

@end

