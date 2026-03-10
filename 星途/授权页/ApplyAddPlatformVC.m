//
//  ApplyAddPlatformVC.m
//  星途
//
//  Created by  on 2020/3/27.
//  
//

#import "ApplyAddPlatformVC.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "VideoPlayerVC.h"

@interface ApplyAddPlatformVC ()
@property (weak, nonatomic) IBOutlet UITextField *platformNameLabe;
@property (weak, nonatomic) IBOutlet UIButton *loginAuthBtn;
@property (weak, nonatomic) IBOutlet UIButton *bindAuthBtn;
@property (weak, nonatomic) IBOutlet UITextField *contactText;

@property (weak, nonatomic) IBOutlet UITextView *describeTextView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UITextField *wxNickName;


@property (nonatomic, strong) NSString *type;

@end

@implementation ApplyAddPlatformVC

+ (ApplyAddPlatformVC *)vc {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ApplyAddPlatformVC" bundle:nil];
    ApplyAddPlatformVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"ApplyAddPlatformVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.type = @"登录授权";
    // 通过运行时，发现UITextView有一个叫做“_placeHolderLabel”的私有变量
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([UITextView class], &count);
    
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        NSString *objcName = [NSString stringWithUTF8String:name];
        NSLog(@"%d : %@",i,objcName);
    }
    [self setupTextView];
    
    if (self.param) {
        self.iconImageView.fd_collapsed = NO;
        self.wxNickName.fd_collapsed = NO;
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:self.param[@"imageUrl"]] placeholderImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#D8D8D8"]]];
        self.wxNickName.text = self.param[@"wxNickname"];
    } else {
        self.iconImageView.fd_collapsed = YES;
        self.wxNickName.fd_collapsed = YES;
    }
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"教程" style:UIBarButtonItemStylePlain target:self action:@selector(applyCourse)];
    self.navigationItem.rightBarButtonItem = rightItem;

}

- (void)applyCourse {
    VideoPlayerVC *vc = [[VideoPlayerVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setupTextView
{
    // _placeholderLabel
    UILabel *placeHolderLabel = [[UILabel alloc] init];
    placeHolderLabel.text = @"请输入关于该平台的简要描述，如果是非AppStore的APP，请提供下载链接，以便客服添加。";
    placeHolderLabel.numberOfLines = 0;
    placeHolderLabel.textColor = [UIColor lightGrayColor];
    [placeHolderLabel sizeToFit];
    [self.describeTextView addSubview:placeHolderLabel];
    // same font
    self.describeTextView.font = [UIFont systemFontOfSize:15.f];
    placeHolderLabel.font = [UIFont systemFontOfSize:15.f];
    
    [self.describeTextView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
}

- (IBAction)selectLoginAuthAction:(id)sender {
    self.type = @"登录授权";
    [self.loginAuthBtn setImage:[UIImage imageNamed:@"icon_select_seleted"] forState:UIControlStateNormal];
    [self.bindAuthBtn setImage:[UIImage imageNamed:@"icon_select_gray"] forState:UIControlStateNormal];
    
}

- (IBAction)selectBindAuthAction:(id)sender {
    self.type = @"代绑授权";
    [self.loginAuthBtn setImage:[UIImage imageNamed:@"icon_select_gray"] forState:UIControlStateNormal];
    [self.bindAuthBtn setImage:[UIImage imageNamed:@"icon_select_seleted"] forState:UIControlStateNormal];
}

- (IBAction)applyAction:(id)sender {
    NSString *platform = self.platformNameLabe.text;
    if ([platform isEqualToString:@""] || platform.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入需要添加的平台名字"];
        return;
    }
    NSString *contact = self.contactText.text;
    if ([contact isEqualToString:@""] || contact.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入联系方式"];
        return;
    }
    NSString *des = self.describeTextView.text;
    if (des.length >= 150) {
        [SVProgressHUD showErrorWithStatus:@"平台简要描述最多输入150字。"];
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@/platformApply", baseUrl];
    NSDictionary *parameters;
    if (des.length > 0) {
        if (self.param) {
            parameters = @{
                @"platformName": platform,
                @"description": des,
                @"type": self.type,
                @"contact": contact,
                @"appId": self.param[@"appid"],
                @"bundleId": self.param[@"bundleid"] ? self.param[@"bundleid"] : @"",
                @"scope": self.param[@"scope"],
                @"nickname": self.param[@"wxNickname"],
                @"imageUrl": self.param[@"imageUrl"],
                @"device": @"1"
            };
        } else {
            parameters = @{@"platformName": platform, @"description": des, @"type": self.type, @"contact": contact};
        }
    } else {
        if (self.param) {
            parameters = @{
                @"platformName": platform,
                @"type": self.type,
                @"contact": contact,
                @"appId": self.param[@"appid"],
                @"bundleId": self.param[@"bundleid"] ? self.param[@"bundleid"] : @"",
                @"scope": self.param[@"scope"],
                @"nickname": self.param[@"wxNickname"],
                @"imageUrl": self.param[@"imageUrl"],
                @"device": @"1"
            };
        } else {
            parameters = @{@"platformName": platform, @"type": self.type, @"contact": contact};
        }
    }
    [SVProgressHUD show];
    [[NetworkingManager manager] postDataWithUrl:url parameters:parameters success:^(id json) {
        [SVProgressHUD showSuccessWithStatus:@"提交申请成功，请耐心等待客服审核"];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {;
    }];
}

- (void)addNewPlatformWithName:(NSString *)platform {
    
}


@end
