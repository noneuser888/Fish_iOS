//
//  PlatformListCell.m
//  星途
//
//  Created by  on 2020/2/24.
//  
//

#import "PlatformListCell.h"

@interface PlatformListCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *autoAuthPriceLabel; //扫码价格
@property (weak, nonatomic) IBOutlet UILabel *qrPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *channelLabel;


@end

@implementation PlatformListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void )setData:(NSDictionary *)data {
    if ([NSString nullToString: data[@"nickname"]]) {
        self.titleLabel.text = [NSString nullToString: data[@"nickname"]];
    } else {
        self.titleLabel.text = [NSString nullToString: data[@"platformName"]];
    }
    NSString *type = [[UserInfoModel shared] getAccountType];
    if ([type isEqualToString:@"1"]) {
        self.autoAuthPriceLabel.text = [NSString stringWithFormat:@"一键授权：%.2f",[data[@"price1"] floatValue]];
        self.channelLabel.text = [NSString stringWithFormat:@"供应商：%@", [NSString nullToString:data[@"channel1"]]];
    } else if ([type isEqualToString:@"2"]) {
        self.autoAuthPriceLabel.text = [NSString stringWithFormat:@"一键授权：%.2f",[data[@"price2"] floatValue]];
        self.channelLabel.text = [NSString stringWithFormat:@"供应商：%@", [NSString nullToString:data[@"channel2"]]];
    } else {
        self.autoAuthPriceLabel.text = [NSString stringWithFormat:@"一键授权：%.2f",[data[@"price3"] floatValue]];
        self.channelLabel.text = [NSString stringWithFormat:@"供应商：%@", [NSString nullToString:data[@"channel3"]]];
    }
    self.qrPriceLabel.text = [NSString stringWithFormat:@"显码：%.2f",[data[@"qrPrice"] floatValue]];

//    if ([data[@"usableNum"] integerValue] <= 0) {
//        self.numLabel.text = @"余量：0";
//    } else {
//        self.numLabel.text = [NSString stringWithFormat:@"余量：%@", data[@"usableNum"]];
//    }
//    if (data[@"bbyMoney"]) {
//        self.unitPriceLabel.hidden = NO;
//        self.blurImgView.hidden = YES;
//        self.unitPriceLabel.text = [NSString stringWithFormat:@"单价:%.2f~%.2f", [data[@"userMoney"] floatValue], [data[@"bbyMoney"] floatValue]];
//    } else {
//        self.unitPriceLabel.hidden = YES;
//        self.blurImgView.hidden = NO;
//    }
//    if (data[@"userMoney"]) {
//        self.autoAuthPriceLabel.hidden = NO;
//        self.blurImgView2.hidden = YES;
//        self.autoAuthPriceLabel.text = [NSString stringWithFormat:@"单价:%.2f", [data[@"userMoney"] floatValue]];
//    } else {
//        self.autoAuthPriceLabel.hidden = YES;
//        self.blurImgView2.hidden = NO;
//    }
//    self.iconImageView.layer.cornerRadius = 5.0f;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:data[@"imageUrl"]] placeholderImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#D8D8D8"]]];
    //    [iconImageView sd_web]
    
}

- (IBAction)scanQRAction:(UIButton *)sender {
    if (self.scanQRActionBlock) {
        self.scanQRActionBlock();
    }
}


@end
