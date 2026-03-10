//
//  ChargeVC.m
//

#import "ChargeVC.h"

@interface ChargeVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UITextField *customText;  //自定义金额

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *moneyNOBtnArray;

@property (nonatomic, strong) void(^chargeBlock)(void);

@property (nonatomic, strong) NSDictionary *model;

@property (nonatomic, assign) float chargeMoney;


@end

@implementation ChargeVC

+ (ChargeVC *)vc:(NSDictionary *)model ChargeBlock:(void (^)(void))chargeBlock {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChargeVC" bundle:nil];
    ChargeVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChargeVC"];
    vc.chargeBlock = chargeBlock;
    vc.model = model;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshUserInfo];
    self.accountLabel.text = [NSString stringWithFormat:@"账号：%@  %@", self.model[@"phone"], self.model[@"nickname"]];
    self.chargeMoney = 0;
    self.customText.delegate = self;
    [self.customText addTarget:self action:@selector(changedTextField:) forControlEvents:UIControlEventEditingChanged];
    // Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshUserInfo];
}

- (void)refreshUserInfo {
    NSDictionary *userInfo = [UserInfoModel shared].userInfo;
    self.phoneLabel.text = userInfo[@"phone"];
    self.nicknameLabel.text = userInfo[@"nickname"];
    self.balanceLabel.text = [NSString stringWithFormat:@"余额:￥%@", userInfo[@"balance"]];
    self.userTypeLabel.text = [UserInfoModel userLevel:[userInfo[@"level"] integerValue]];
}

- (IBAction)selectMoneyAction:(UIButton *)sender {
    self.customText.text = @"";
    [self.customText resignFirstResponder];
    for (UIButton *item in self.moneyNOBtnArray) {
        if (item.tag == sender.tag) {
            item.app_borderColor = [UIColor colorWithHexString:@"#DDB86A"];
        } else {
            item.app_borderColor = [UIColor colorWithHexString:@"#E8E8E8"];
        }
    }
    
    self.chargeMoney = (float)sender.tag;
}


- (IBAction)chargeAction:(id)sender {
    NSDictionary *userInfo = [UserInfoModel shared].userInfo;
    float balance = [userInfo[@"balance"] floatValue];
    if (self.chargeMoney <= 0) {
        [SVProgressHUD showErrorWithStatus:@"充值金额不能 0"];
        return;
    } else if (self.chargeMoney > balance) {
        [SVProgressHUD showErrorWithStatus:@"余额不足，请联系客服充值"];
        return;
    } else {
        [self.customText resignFirstResponder];
        @weakify(self);
        [self alert:@"充值" message:[NSString stringWithFormat:@"给账户 %@ 充值 %.2f 元", self.model[@"phone"], self.chargeMoney] handler:^(UIAlertAction *action) {
            @strongify(self);
            NSString *url = [NSString stringWithFormat:@"%@/recharge", baseUrl];
            NSDictionary *param = @{@"userId": self.model[@"id"], @"amount": @(self.chargeMoney)};
            [SVProgressHUD show];
            [[NetworkingManager manager] postDataWithUrl:url parameters:param success:^(id json) {
                @strongify(self);
                [SVProgressHUD showSuccessWithStatus:@"充值成功"];
                [UserInfoModel requestInfo:^(NSDictionary * _Nullable data) {
                    @strongify(self);
                    [self refreshUserInfo];
                    if (self.chargeBlock) {
                        self.chargeBlock();
                    }
                }];
            } failure:nil];
        }];
    }
}

- (void)changedTextField:(UITextField *)textField {
    float customMoney = [textField.text floatValue];
    self.chargeMoney = customMoney;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    for (UIButton *item in self.moneyNOBtnArray) {
        item.app_borderColor = [UIColor colorWithHexString:@"#E8E8E8"];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //    限制只能输入数字
    BOOL isHaveDian = YES;
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    
    if ([textField.text rangeOfString:@"."].location == NSNotFound) {
        isHaveDian = NO;
    }
    if ([string length] > 0) {
        unichar single = [string characterAtIndex:0];//当前输入的字符
        if ((single >= '0' && single <= '9') || single == '.') {//数据格式正确
            if([textField.text length] == 0){
                if(single == '.') {
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }
            //输入的字符是否是小数点
            if (single == '.') {
                if(!isHaveDian)//text中还没有小数点
                {
                    isHaveDian = YES;
                    return YES;
                }else{
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }else{
                if (isHaveDian) {//存在小数点
                    //判断小数点的位数
                    NSRange ran = [textField.text rangeOfString:@"."];
                    if (range.location - ran.location <= 2) {
                        return YES;
                    }else{
                        
                        return NO;
                    }
                }else{
                    return YES;
                }
            }
        }else{//输入的数据格式不正确
            [textField.text stringByReplacingCharactersInRange:range withString:@""];
            return NO;
        }
    }
    else
    {
        return YES;
    }
}

- (void)alert:(NSString*) title message:(NSString*) message handler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:handler];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertCtrl addAction:action];
    [alertCtrl addAction:cancelAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}
@end
