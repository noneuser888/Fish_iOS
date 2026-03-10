//
//  BindEmailVC.m
//  星途
//
//  Created by  on 2020/4/13.
//  
//

#import "FindPasswordVC.h"

@interface FindPasswordVC ()
@property (weak, nonatomic) IBOutlet UITextField *acountText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeText;

@property (weak, nonatomic) IBOutlet ZXAutoCountDownBtn *getVerifyCodeBtn;

@end

@implementation FindPasswordVC

+ (instancetype)vc{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FindPasswordVC" bundle:nil];
    FindPasswordVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"FindPasswordVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    [self.getVerifyCodeBtn enableAutoCountDown:60 mark:@"GetEmailVerifyCode" resTextFormat:^NSString *(long remainSec) {
        NSLog(@"%ld",remainSec);
        @strongify(self);
        if (remainSec > 0) {
            [self.getVerifyCodeBtn setTitleColor:[UIColor colorWithHexString:@"#D8D8D8"] forState:UIControlStateNormal];
        } else {
            [self.getVerifyCodeBtn setTitleColor:[UIColor colorWithHexString:@"#23ADE4"] forState:UIControlStateNormal];
        }
        return [NSString stringWithFormat:@"重新发送(%ld)",remainSec];
    }];
    
}

- (IBAction)findPasswordAction:(UIButton *)sender {
    [self hideKeyboard];
    NSString *account = self.acountText.text;
    NSString *password = self.passwordText.text;
    NSString *verifyCode = self.verifyCodeText.text;
    if ([self isMobileNumberOnly:account]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号"];
        return;
    }
    if (!password || [password isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入新密码"];
        return;
    }
    if (!verifyCode || [verifyCode isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@/resetPassword", baseUrl];
    NSDictionary *param = @{@"username": account,
                            @"code": verifyCode,
                            @"password" : password
    };
    @weakify(self);
    [SVProgressHUD show];
    [[NetworkingManager manager] postDataWithUrl:url parameters:param success:^(id json) {
        @strongify(self);
        [SVProgressHUD showSuccessWithStatus:@"密码重置成功，请重新登录"];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:nil];
    
}


- (BOOL)isMobileNumberOnly:(NSString *)mobileNum {
    
    NSString * MOBILE = @"^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\\d{8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    if ([regextestmobile evaluateWithObject:mobileNum] == YES) {
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)getVerifyCodeAction:(UIButton *)sender {
    [self hideKeyboard];
    NSString *account = self.acountText.text;
    if (!account || [account isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入登录账号"];
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@/sendEmail", baseUrl];
    NSDictionary *param = @{@"username": account};
    @weakify(self);
    [SVProgressHUD show];
    [[NetworkingManager manager] postDataWithUrl:url parameters:param success:^(id json) {
        @strongify(self);
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"验证码发送成功，请注意查收"];
        [self.getVerifyCodeBtn startCountDown];
    } failure:nil];
    
}


- (void)hideKeyboard {
    [self.acountText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    [self.verifyCodeText resignFirstResponder];
}

@end
