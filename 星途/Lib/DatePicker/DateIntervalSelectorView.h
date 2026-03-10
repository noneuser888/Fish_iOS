//
//  DateIntervalSelectorView.h
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DateIntervalSelectorView : UIView

//单例
+(DateIntervalSelectorView *)shared;

-(void)datePickerCompleteBlock:(void (^)(NSDate *startDate, NSDate *endDate))completeBlock;

@end

NS_ASSUME_NONNULL_END
