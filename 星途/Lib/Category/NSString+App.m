//
//  NSString+App.m
//  星途
//
//  Created by  on 2020/3/14.
//  
//

#import "NSString+App.h"

@interface AppDateFormatter : NSDateFormatter
@property(strong,nonatomic)NSLock* lock;
@end

@implementation AppDateFormatter
- (id)init
{
    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc]init];
        self.generatesCalendarDates = YES;
        self.dateStyle = NSDateFormatterNoStyle;
        self.timeStyle = NSDateFormatterNoStyle;
        self.AMSymbol = nil;
        self.PMSymbol = nil;
//        NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"GMT"];
//        [self setTimeZone:tz];
//        NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
//        if(locale){
//            [self setLocale:locale];
//        }
    }
    return self;
}
//防止在IOS5下 多线程 格式化时间时 崩溃
-(NSDate *)dateFromString:(NSString *)string
{
    [_lock lock];
    NSDate* date = [super dateFromString:string];
    [_lock unlock];
    return date;
}
-(NSString *)stringFromDate:(NSDate *)date
{
    [_lock lock];
    NSString* string = [super stringFromDate:date];
    [_lock unlock];
    return string;
}
@end


@implementation NSString (App)

/**
*  将时间转换为可读的友好的方式显示
*/
+ (NSString *)coverDataTimeToHunmanTime:(NSString *)timeStr {
    NSString *hunmanTime = @"未知时间";
    
    if (timeStr == nil) {
        return hunmanTime;
    }
    
    NSDate *inputDate = [[self secondDateFormat] dateFromString:timeStr];
    NSTimeInterval inputTimestamp = [inputDate timeIntervalSince1970];
    NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
    
    if (inputTimestamp > currentTimestamp) {
        return hunmanTime;
    }
    
    NSTimeInterval poor = currentTimestamp - inputTimestamp;
    if (poor <= 60 * 60) {
        hunmanTime = [NSString stringWithFormat:@"%d分钟前", (int)poor / 60];
    } else if (poor > 60 * 60 && poor < 60 * 60 * 24) {
        hunmanTime = [NSString stringWithFormat:@"%d小时前", (int)poor / (60 * 60)];
    } else if (poor > 60 * 60 * 24 && poor < 60 * 60 * 24 * 3) {
        hunmanTime = [NSString stringWithFormat:@"%d天前", (int)poor / (60 * 60 * 24)];
    } else {
        hunmanTime = [self stringWithDate:inputDate dateFormatterType:DateFormatterTypeDay];
    }
    return hunmanTime;
}

+ (NSString *)stringWithDate:(NSDate *)date dateFormatterType:(DateFormatterType)type{
    NSDateFormatter* formatter = [self dayDateFormat];
    switch (type) {
        case DateFormatterTypeSecond:
            formatter = [self secondDateFormat];
            break;
        case DateFormatterTypeMinute:
            formatter = [self minuteDateFormat];
            break;
        case DateFormatterTypeMinute2:
            formatter = [self minuteDateFormat2];
            break;
        case DateFormatterTypeDay:
            formatter = [self dayDateFormat];
            break;
        case DateFormatterTypeMonth:
            formatter = [self monthDateFormat];
            break;
    }
    NSString *timeStr = [formatter stringFromDate:date];
    return timeStr;
}

+ (NSDateFormatter *)secondDateFormat
{
    static NSDateFormatter* format;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        format = [[AppDateFormatter alloc]init];
        format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    });
    return format;
}

+ (NSDateFormatter *)minuteDateFormat
{
    static NSDateFormatter* format;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        format = [[AppDateFormatter alloc] init];
        format.dateFormat = @"yyyy-MM-dd HH:mm";
    });
    return format;
}

+ (NSDateFormatter *)minuteDateFormat2
{
    static NSDateFormatter* format;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        format = [[AppDateFormatter alloc] init];
        format.dateFormat = @"yyyy.MM.dd HH:mm";
    });
    return format;
}

+ (NSDateFormatter *)dayDateFormat
{
    static NSDateFormatter* format;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        format = [[AppDateFormatter alloc]init];
        format.dateFormat = @"yyyy-MM-dd";
    });
    return format;
}

+ (NSDateFormatter *)monthDateFormat
{
    static NSDateFormatter* format;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        format = [[AppDateFormatter alloc]init];
        format.dateFormat = @"yyyy-MM";
    });
    return format;
}

+ (NSString *)nullToString:(id)string {
    if ([string isEqual:@"NULL"] || [string isKindOfClass:[NSNull class]] || [string isEqual:[NSNull null]] || [string isEqual:NULL] || [[string class] isSubclassOfClass:[NSNull class]] || string == nil || string == NULL || [string isKindOfClass:[NSNull class]] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0 || [string isEqualToString:@"<null>"] || [string isEqualToString:@"(null)"]) {
        return @"";
    } else {
        return (NSString *)string;
    }
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSArray *)arrayWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return array;
}


+ (BOOL)cly_verifyIDCardString:(NSString *)idCardString {
    NSString *regex = @"^[1-9]\\d{5}(18|19|([23]\\d))\\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isRe = [predicate evaluateWithObject:idCardString];
    if (!isRe) {
         //身份证号码格式不对
        return NO;
    }
    //加权因子 7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2
    NSArray *weightingArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
    //校验码 1, 0, 10, 9, 8, 7, 6, 5, 4, 3, 2
    NSArray *verificationArray = @[@"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
    
    NSInteger sum = 0;//保存前17位各自乖以加权因子后的总和
    for (int i = 0; i < weightingArray.count; i++) {//将前17位数字和加权因子相乘的结果相加
        NSString *subStr = [idCardString substringWithRange:NSMakeRange(i, 1)];
        sum += [subStr integerValue] * [weightingArray[i] integerValue];
    }
    
    NSInteger modNum = sum % 11;//总和除以11取余
    NSString *idCardMod = verificationArray[modNum]; //根据余数取出校验码
    NSString *idCardLast = [idCardString.uppercaseString substringFromIndex:17]; //获取身份证最后一位
    
    if (modNum == 2) {//等于2时 idCardMod为10  身份证最后一位用X表示10
        idCardMod = @"X";
    }
    if ([idCardLast isEqualToString:idCardMod]) { //身份证号码验证成功
        return YES;
    } else { //身份证号码验证失败
        return NO;
    }
}

@end
