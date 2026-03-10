//
//  UserListCell.h
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserListCell : UITableViewCell

@property (nonatomic, strong) void(^addRemarkBlock)(void);
@property (nonatomic, strong) void(^chargeBlock)(void);
@property (nonatomic, strong) void(^bannedBlock)(void);
@property (nonatomic, strong) void(^upgradeUserBlock)(void);
@property (weak, nonatomic) IBOutlet UIButton *upgradeUserBtn;

- (void)setData:(NSDictionary *)model;

@end

NS_ASSUME_NONNULL_END
