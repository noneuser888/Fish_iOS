//
//  UserListCell.m
//

#import "UserListCell.h"

@interface UserListCell()

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *userStatusTypeBtn;

@end

@implementation UserListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setData:(NSDictionary *)model {
    self.phoneLabel.text = [NSString nullToString:model[@"phone"]];
    NSString *remark = [NSString nullToString:model[@"remark"]];
    self.remarkLabel.text = remark.length == 0 ? @"":[NSString stringWithFormat:@"(%@)",remark];
    self.balanceLabel.text = [NSString stringWithFormat:@"余额:￥%@", model[@"balance"]];
    NSInteger status = [model[@"status"] integerValue];
    [self.userStatusTypeBtn setTitle:status == 0 ? @"封禁":@"解封" forState:UIControlStateNormal];
    self.phoneLabel.superview.backgroundColor = [UIColor colorWithHexString:status == 0 ? @"#FFFFFF":@"#E9E9E9"];
}

- (IBAction)addRemarkAction:(id)sender {
    if (self.addRemarkBlock) {
        self.addRemarkBlock();
    }
}

- (IBAction)chargeAction:(id)sender {
    if (self.chargeBlock) {
        self.chargeBlock();
    }
}

- (IBAction)bannedAction:(id)sender {
    if (self.bannedBlock) {
        self.bannedBlock();
    }
}

- (IBAction)upgradeUserToAgencyAction:(id)sender {
    if (self.upgradeUserBlock) {
        self.upgradeUserBlock();
    }
}


@end
