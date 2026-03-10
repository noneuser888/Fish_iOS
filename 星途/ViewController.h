//
//  ViewController.h
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) NSDictionary *paramDic;

-(void)loadQRCodeImg:(NSString *)url;

- (void)getQRCodeWithParam:(NSDictionary *)param;

@end

