//
//  ProtocolVC.m
//  星途
//
//

#import "ProtocolVC.h"

@interface ProtocolVC ()

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) NSString *urlProtocol;

@property (nonatomic, strong) UITextView *contentText;

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;


@end

@implementation ProtocolVC

+ (ProtocolVC *)vc {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ProtocolVC" bundle:nil];
    ProtocolVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"ProtocolVC"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.confirmBtn.enabled = NO;
    self.contentText = [[UITextView alloc] init];
    self.contentText.font = [UIFont systemFontOfSize:14];
    [self.contentText setTextColor:[UIColor colorWithHexString:@"#444444"]];
    [self.containerView addSubview:self.contentText];
    [self.contentText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
    if (self.type == 1) { //免责声明
        self.urlProtocol = [NSString stringWithFormat:@"%@/protocol", baseUrl];
        self.titleLab.text = @"免责声明";
    } else if (self.type == 2) { //用户服务协议
        self.urlProtocol = [NSString stringWithFormat:@"%@/protocol", baseUrl];
        self.titleLab.text = @"用户服务协议";
    }
    @weakify(self);
    [[NetworkingManager manager]
     getDataWithUrl:self.urlProtocol
     parameters:nil
     success:^(id json) {
        @strongify(self);
        NSDictionary *data = json[@"data"];
        self.confirmBtn.enabled = YES;
        if (self.type == 2) {
           self.contentText.text = data[@"userAgreement"];
        } else {
             self.contentText.text = data[@"disclaimer"];
        }
    } failure:nil];
    
}


- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)confirmAction:(id)sender {
    if (self.consumeBlock) {
        self.consumeBlock();
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
