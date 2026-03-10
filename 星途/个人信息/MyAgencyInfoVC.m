//
//  MyAgencyInfoVC.m
//

#import "MyAgencyInfoVC.h"

@interface MyAgencyInfoVC ()

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *agencyLabel;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContainerViewHeight;


@end

@implementation MyAgencyInfoVC

+ (MyAgencyInfoVC *)vc {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MyAgencyInfoVC" bundle:nil];
    MyAgencyInfoVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"MyAgencyInfoVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *userInfo = [UserInfoModel shared].userInfo;
    self.fd_prefersNavigationBarHidden = YES;
    if ([UIScreen mainScreen].bounds.size.height < 812) {
        self.topContainerViewHeight.constant = 64;
    } else {
        self.topContainerViewHeight.constant = 88;
    }
    self.phoneLabel.text = userInfo[@"phone"];
    self.balanceLabel.text = [NSString stringWithFormat:@"余额:￥%@", userInfo[@"balance"]];
    self.agencyLabel.text = [NSString stringWithFormat:@"我的代理：%@ %@", [NSString nullToString:userInfo[@"myAgency"]], [NSString nullToString:userInfo[@"myAgencyNickname"]]];
    self.contentLabel.text = @"代理优势：\n1.您将会获得更优惠充值折扣 \n2.您可以给普通用户充值 \n3.您可以拥有更高一级的权限 \n4.联系上级成为代理 \n...";
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
