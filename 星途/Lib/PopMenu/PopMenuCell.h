//
//  PopMenuCell.h
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PopMenuType) {
    PopMenuTypeNormal,
    PopMenuTypeOnlyTitle,
    PopMenuTypeOnlyIcon,
};

@interface PopMenuCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) PopMenuType showType;

@end

