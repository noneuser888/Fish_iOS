//
//  ChargeVC.h
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChargeVC : UIViewController

+ (ChargeVC *)vc:(NSDictionary *)model ChargeBlock:(void (^)(void))chargeBlock;

@end

NS_ASSUME_NONNULL_END
