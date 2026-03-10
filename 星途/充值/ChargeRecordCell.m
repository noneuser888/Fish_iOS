//
//  ChargeRecordCell.m
//

#import "ChargeRecordCell.h"

@interface ChargeRecordCell()

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chargeNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeAmountLabel;


@end

@implementation ChargeRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setData:(NSDictionary *)model {
    self.phoneLabel.text = [NSString nullToString:model[@"phone"]];
    self.chargeTypeLabel.text = [NSString stringWithFormat:@"类型：%@", model[@"rechargeType"]];
    self.orderIdLabel.text = [NSString stringWithFormat:@"订单ID：%@", model[@"id"]];
    NSInteger type = [model[@"type"] integerValue];
    if (type == 1) {
        self.chargeAmountLabel.text = [NSString stringWithFormat:@"+%.2f", [model[@"amount"] floatValue]];
        self.chargeAmountLabel.textColor = [UIColor colorWithHexString:@"#E03114"];
    } else {
        self.chargeAmountLabel.text = [NSString stringWithFormat:@"-%.2f", [model[@"amount"] floatValue]];
        self.chargeAmountLabel.textColor = [UIColor colorWithHexString:@"00FF00"];
    }
    self.chargeTimeLabel.text = model[@"time"];//[NSString stringWithFormat:@""]
    self.balanceLabel.text = [NSString stringWithFormat:@"￥%.2f", [model[@"afterBalance"] floatValue]];
}


@end
