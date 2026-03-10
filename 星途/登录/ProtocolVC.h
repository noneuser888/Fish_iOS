//
//  ProtocolVC.h
//  星途
//
//

#import <UIKit/UIKit.h>


@interface ProtocolVC : UIViewController

@property (nonatomic, strong) void(^consumeBlock)(void);

@property (nonatomic, assign) NSInteger type; //1.免责声明  2.用户服务协议

+ (ProtocolVC *)vc;

@end

