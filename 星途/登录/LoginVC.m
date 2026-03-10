//
//  LoginVC.m
//  星途
//
//  Created by  on 2020/2/21.
//  
//

#import "LoginVC.h"
#import "ViewController.h"
#import "NavController.h"
#import "FindPasswordVC.h"
#import "ProtocolVC.h"

@interface LoginVC ()

@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderViewLeftConstraint;


//Login
@property (weak, nonatomic) IBOutlet UITextField *loginAccountText;
@property (weak, nonatomic) IBOutlet UITextField *loginPasswordText;


//Register
@property (weak, nonatomic) IBOutlet UITextField *registerAccountText;
@property (weak, nonatomic) IBOutlet UITextField *registerPasswordText;
@property (weak, nonatomic) IBOutlet UITextField *registerPassword2Text;
@property (weak, nonatomic) IBOutlet UITextField *inviteCodeText;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeText;
@property (weak, nonatomic) IBOutlet ZXCountDownBtn *getVerifyCodeBtn;

@property (weak, nonatomic) IBOutlet UIButton *protocolSelectBtn;


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, assign) BOOL isConsumeProtocol;


@end

@implementation LoginVC

+ (void)showLoginVC:(UIViewController *)currentVc {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginVC" bundle:nil];
    LoginVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    NavController *nav = [[NavController alloc] initWithRootViewController:vc];
    [currentVc presentViewController:nav animated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.isConsumeProtocol = NO;
    self.loginAccountText.text = [[StoreService shared] getString:@"Account.Phone"];
    self.loginPasswordText.text = [[StoreService shared] getString:@"Account.Password"];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}



//Login
- (IBAction)findPasswordAction:(id)sender {
    [self.loginAccountText resignFirstResponder];
    [self.loginPasswordText resignFirstResponder];
    FindPasswordVC *vc = [FindPasswordVC vc];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)loginActon:(id)sender {
    [self.loginAccountText resignFirstResponder];
    [self.loginPasswordText resignFirstResponder];
    NSString *phone = self.loginAccountText.text;
    NSString *password = self.loginPasswordText.text;
    if (!self.isConsumeProtocol) {
        @weakify(self);
        ProtocolVC *vc = [ProtocolVC vc];
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        vc.type = 2;
        vc.consumeBlock = ^{
            @strongify(self);
            self.isConsumeProtocol = YES;
        };
        [self presentViewController:vc animated:NO completion:nil];
        return;
    }
    if (phone.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号"];
        return;
    } else if (password.length == 0 || [password isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
        return;
    } else {
        [SVProgressHUD showWithStatus:@"登录中..."];
        NSString *url = [NSString stringWithFormat:@"%@/login", baseUrl];
        NSDictionary *param = @{@"phone": phone,
                                @"password": password};
        @weakify(self);
        [[NetworkingManager manager] postDataWithUrl:url
                                          parameters:param
                                             success:^(id json) {
            [SVProgressHUD showSuccessWithStatus:@"登录成功！"];
            NSDictionary *data = (NSDictionary *)json[@"data"];
            NSString *token = (NSString *)data[@"token"];
            [[UserInfoModel shared] setLoginToken:token];
            [UserInfoModel shared].userInfo = data;
            [[UserInfoModel shared] setLogin:YES];
            [[StoreService shared] setString:phone forKey:@"Account.Phone"];
            [[StoreService shared] setString:password forKey:@"Account.Password"];
            @strongify(self);
            [self dismissViewControllerAnimated:YES completion:^{
                [UserInfoModel requestInfo:nil];
            }];
        } failure:^(NSError *error) {
            
        }];
    }
    
}

//Register
//获取注册验证码
- (IBAction)getRegisterAction:(id)sender {
    NSString *phone = self.registerAccountText.text;
    if (![self isMobileNumberOnly:phone]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号"];
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@/sendSms", baseUrl];
    NSDictionary *param = @{@"phone": phone};
    [SVProgressHUD show];
    [[NetworkingManager manager] postDataWithUrl:url parameters:param success:^(id json) {
        [SVProgressHUD showSuccessWithStatus:@"短信验证码，发送成功"];
    } failure:nil];
}

- (IBAction)registerRequest:(id)sender {
    [self.registerAccountText resignFirstResponder];
    [self.registerPasswordText resignFirstResponder];
    [self.registerPassword2Text resignFirstResponder];
    [self.inviteCodeText resignFirstResponder];
    [self.verifyCodeText resignFirstResponder];
    NSString *phone = self.registerAccountText.text;
    NSString *password1 = self.registerPasswordText.text;
    NSString *password2 = self.registerPassword2Text.text;
    NSString *inviteCode = self.inviteCodeText.text;
    NSString *verifyCode = self.verifyCodeText.text;
    if (!self.isConsumeProtocol) {
        @weakify(self);
        ProtocolVC *vc = [ProtocolVC vc];
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        vc.type = 2;
        vc.consumeBlock = ^{
            @strongify(self);
            self.isConsumeProtocol = YES;
        };
        [self presentViewController:vc animated:NO completion:nil];
        return;
    }
    if (![self isMobileNumberOnly:phone]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号"];
        return;
    }
    if (password1.length == 0 || [password1 isEqualToString:@""] || password2.length == 0 || [password2 isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
        return;
    }
    if (![password1 isEqualToString:password2]) {
        [SVProgressHUD showErrorWithStatus:@"密码不一致，请重新输入"];
        return;
    }
    if (inviteCode.length == 0 || [inviteCode isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入邀请码"];
        return;
    }
    if (verifyCode.length == 0 || [verifyCode isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@/register", baseUrl];
    NSDictionary *param = @{
        @"phone": phone,
        @"password": password1,
        @"inviteCode": inviteCode,
        @"verifyCode": verifyCode
    };
    [SVProgressHUD show];
    @weakify(self);
    [[NetworkingManager manager] postDataWithUrl:url parameters:param success:^(id json) {
        [SVProgressHUD showSuccessWithStatus:@"恭喜您💐💐💐，注册成功"];
        @strongify(self);
        self.loginAccountText.text = phone;
        self.loginPasswordText.text = password1;
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        self.sliderViewLeftConstraint.constant = 0;
        [UIView animateWithDuration:0.5 animations:^{
            [self.sliderView.superview layoutIfNeeded];
        }];
        [[StoreService shared] setString:phone forKey:@"Account.Phone"];
        [[StoreService shared] setString:password1 forKey:@"Account.Password"];
    } failure:nil];
    
}

//Common

- (IBAction)changeLoginAction:(id)sender {
    [self.registerAccountText resignFirstResponder];
    [self.registerPasswordText resignFirstResponder];
    [self.registerPassword2Text resignFirstResponder];
    [self.inviteCodeText resignFirstResponder];
    [self.verifyCodeText resignFirstResponder];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.sliderViewLeftConstraint.constant = 0;
    [UIView animateWithDuration:0.5 animations:^{
        [self.sliderView.superview layoutIfNeeded];
    }];
}

- (IBAction)changeRegisterAction:(id)sender {
    [self.loginAccountText resignFirstResponder];
    [self.loginPasswordText resignFirstResponder];
    [self.scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0) animated:YES];
    self.sliderViewLeftConstraint.constant = 65;
    [UIView animateWithDuration:0.5 animations:^{
        [self.sliderView.superview layoutIfNeeded];
    }];
}

- (IBAction)userProtocolAction:(id)sender {
    @weakify(self);
    ProtocolVC *vc = [ProtocolVC vc];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.type = 2;
    vc.consumeBlock = ^{
        @strongify(self);
        self.isConsumeProtocol = YES;
    };
    [self presentViewController:vc animated:NO completion:nil];
}

- (IBAction)disclaimerAction:(id)sender {
    @weakify(self);
    ProtocolVC *vc = [ProtocolVC vc];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    vc.type = 1;
    vc.consumeBlock = ^{
        @strongify(self);
        self.isConsumeProtocol = YES;
    };
    [self presentViewController:vc animated:NO completion:nil];
}


- (IBAction)cancelLoginAction:(UIButton *)sender {
    //    [self.accountText resignFirstResponder];
    //    [self.passwordText resignFirstResponder];
    [self dismissViewControllerAnimated:true completion: nil];
}

- (void)alert:(NSString*) title message:(NSString*) message handler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"立即认证" style:UIAlertActionStyleDefault handler:handler];
    [alertCtrl addAction:action];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (IBAction)protocolSelectAction:(id)sender {
    self.isConsumeProtocol = !self.isConsumeProtocol;
    
}

- (void)setIsConsumeProtocol:(BOOL)isConsumeProtocol {
    _isConsumeProtocol = isConsumeProtocol;
    [self.protocolSelectBtn setImage:[UIImage imageNamed:isConsumeProtocol ? @"protocol_enable" : @"protocol_disable"] forState:UIControlStateNormal];
}

//- (IBAction)findPasswordAction:(UIButton *)sender {
//    [self.accountText resignFirstResponder];
//    [self.passwordText resignFirstResponder];
//    FindPasswordVC *vc = [FindPasswordVC vc];
//    [self.navigationController pushViewController:vc animated:YES];
//}

- (BOOL)isMobileNumberOnly:(NSString *)mobileNum {
    if ([mobileNum hasPrefix:@"1"] && mobileNum.length == 11) {
        return YES;
    } else {
        return NO;
    }
}


@end
