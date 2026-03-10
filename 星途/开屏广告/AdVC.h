//
//  AdVC.h
//  星途
//
//  Created by  on 2020/2/25.
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdVC : UIViewController

@property (nonatomic, assign) BOOL isSkipAd;

- (AdVC *)initWithParameter:(NSDictionary *)parameter;

@end

NS_ASSUME_NONNULL_END
