//
//  VideoPlayerVC.m
//  星途
//
//  Created by  on 2020/4/22.
//  
//

#import "VideoPlayerVC.h"

@interface VideoPlayerVC ()

@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, strong) UIImageView *containerView;
@property (nonatomic, strong) UIButton *playBtn;
//@property (nonatomic, strong) UIButton *closeBtn;

@end

@implementation VideoPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"平台申请教程";
    self.view.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
//    self.closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.view.frame)-85, 30, 60, 35)];
//    [self.closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
//    [self.closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.closeBtn];
    
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.playBtn];
    
    ZFAVPlayerManager *manager = [[ZFAVPlayerManager alloc] init];
    self.player = [ZFPlayerController playerWithPlayerManager:manager containerView:self.containerView];
    self.player.controlView = self.controlView;
    
    
    self.player.assetURLs = @[[NSURL URLWithString:@"https://image.ywxskj.com/wxHelper/apply.mp4"]];
}

- (UIImageView *)containerView {
    if (!_containerView) {
        _containerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-NavHight-StatusHeight)];
        //        [_containerView setIma]
        [_containerView sd_setImageWithURL:[NSURL URLWithString:@"https://image.ywxskj.com/wxHelper/apply.mp4?x-oss-process=video/snapshot,t_0,m_fast,w_414,f_png"] placeholderImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#D8D8D8"]]];
    }
    return  _containerView;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
        _controlView.fastViewAnimated = YES;
        _controlView.autoHiddenTimeInterval = 5;
        _controlView.autoFadeTimeInterval = 0.5;
        _controlView.prepareShowLoading = YES;
        _controlView.prepareShowControlView = YES;
    }
    return _controlView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playBtn.frame = CGRectMake(self.view.frame.size.width/2-22, (self.view.frame.size.height-NavHight-StatusHeight)/2-22, 44, 44);
        [_playBtn setImage:[UIImage imageNamed:@"new_allPlay_44x44_"] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}


- (void)playClick:(UIButton *)sender {
    [self.player playTheIndex:0];
    [self.controlView showTitle:@"平台申请教程" coverURLString:@"https://image.ywxskj.com/wxHelper/apply.mp4?x-oss-process=video/snapshot,t_0,m_fast,w_414,f_png" fullScreenMode:ZFFullScreenModeAutomatic];
}

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
