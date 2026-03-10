//
//  AuthRecordCell.m
//  星途
//
//  Created by  on 2020/2/26.
//  
//

#import "AuthRecordCell.h"

@interface AuthRecordCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *platformLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *wxUserNickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskOrderId;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (nonatomic, strong) UIViewController *parentVC;
@property (nonatomic, strong) NSDictionary *model;

@end

@implementation AuthRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(applyAfterSaleAction)];
    [self.iconImageView addGestureRecognizer:tapGesture];
}

- (void)setData:(NSDictionary *)data {
    self.model = data;
    NSString *wxUserNickname = [NSString nullToString:data[@"wxUserNickname"]];
    if (![wxUserNickname isEqualToString:@""]) {
        self.wxUserNickNameLabel.text = [NSString stringWithFormat:@"%@",wxUserNickname];
    } else {
        self.wxUserNickNameLabel.text = @"";
    }
    if ([[NSString nullToString:data[@"nickname"]] isEqualToString:@""]) {
        self.platformLabel.text = [NSString nullToString:data[@"platformName"]];
    } else {
        self.platformLabel.text = [NSString nullToString:data[@"nickname"]];
    }
    if ([[NSString nullToString:data[@"info"]] isEqualToString:@""]) {
        self.remarkLabel.text = @"";
    } else {
        self.remarkLabel.text = [NSString nullToString:data[@"info"]];
    }
    NSString *type = [NSString stringWithFormat:@"%@", data[@"type"]];
    if ([type isEqualToString:@"0"]) {
        self.nickNameLabel.text = @"显码";
    } else {
        self.nickNameLabel.text = @"一键授权";
    }
    //字符串截取
    NSString *taskId = [NSString nullToString:data[@"id"]];
    if (taskId.length > 12) {
        self.taskOrderId.text = [NSString stringWithFormat:@"订单号：%@", [taskId substringFromIndex:12]];
    }
    self.moneyLabel.text = [NSString stringWithFormat:@"扣费：%.2f", [data[@"price"] floatValue]];
    self.timeLabel.text = [NSString nullToString:data[@"createTime"]];
    
    self.iconImageView.layer.cornerRadius = 5.0f;
    NSString *imageUrl = [NSString nullToString:data[@"imageUrl"]];
    if (imageUrl) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#D8D8D8"]]];
    }
    self.messageLabel.text = [NSString nullToString:data[@"message"]];
    
}

- (void)applyAfterSaleAction {
    NSInteger afterSaleStatus = [self.model[@"afterSaleStatus"] integerValue];
    NSString *orderId = [NSString nullToString:self.model[@"id"]];
    NSString *type = [NSString stringWithFormat:@"%@", self.model[@"type"]];
    if ([type isEqualToString:@"0"]) {
        [SVProgressHUD showErrorWithStatus:@"显码不支持售后"];
        return;
    }
    if ([orderId isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"未获取到该笔订单"];
        return;
    }
    if (afterSaleStatus == 0) { //未售后
        [self applyAfterSaleWithOrderId:self.model[@"id"]];
    } else if (afterSaleStatus == 1) { //已售后
        [SVProgressHUD showSuccessWithStatus:@"该笔订单已成功或已申请过售后，不能重复申请，如有疑问，请联系您的代理"];
        return;
    }
    NSLog(@"xxx");
}

// 售后申请
- (void)applyAfterSaleWithOrderId:(NSString *)orderId {
    NSString *url = [NSString stringWithFormat:@"%@/afterSale/%@", baseUrl, orderId];
    if (orderId == nil) {
        [SVProgressHUD showErrorWithStatus:@"申请售后失败，请到授权记录，申请售后"];
        return;
    }
    [SVProgressHUD showWithStatus:@"售后申请中，请耐心等待"];
    @weakify(self);
    [[NetworkingManager manager]
     postDataWithUrl:url parameters:nil success:^(id json) {
        @strongify(self);
        [SVProgressHUD showSuccessWithStatus:@"申请售后成功，已退款"];
        if (self.applyAfterSaleBlock) {
            self.applyAfterSaleBlock();
        }
        //        [self.navigationController popViewControllerAnimated:YES];
    } failure:nil];
}


@end
