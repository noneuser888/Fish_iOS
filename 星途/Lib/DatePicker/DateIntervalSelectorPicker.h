//
//  DateIntervalSelectorPickerDelegate.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DateIntervalSelectorPickerDelegate <NSObject>

-(void)dateWithSelect:(NSDate *)date;

@end

@interface DateIntervalSelectorPicker : UIPickerView<UIPickerViewDelegate, UIPickerViewDataSource>

-(instancetype)initWithDatePickerView;

@property (nonatomic, assign) id<DateIntervalSelectorPickerDelegate> pvDelegate;

@property (nonatomic, strong, readonly) NSDate *date;

@end


NS_ASSUME_NONNULL_END
