//
//  PlatformListCell.h
//  星途
//
//  Created by  on 2020/2/24.
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlatformListCell : UITableViewCell

@property (nonatomic, strong) void(^scanQRActionBlock)(void);

- (void )setData:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
