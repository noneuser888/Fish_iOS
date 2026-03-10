//
//  ViewController.m
//

#import "ViewController.h"
#import <Photos/Photos.h>

#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <NetworkExtension/NetworkExtension.h>

NSString *base = @"https://open.weixin.qq.com";


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *describeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *all_right_tips_label;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.describeLabel.text = @"请使用手机微信扫描二维码\n授权登录以下应用";
    self.tipsLabel.hidden = YES;
    [self getQRCodeWithParam:nil];
    
//    WKWebViewController *web = [[WKWebViewController alloc] init];
//    [web loadWebURLSring:@"https://open.weixin.qq.com/connect/app/qrconnect?appid=wx13d6c90dabd4f138&bundleid=rn.notes.best&scope=snsapi_userinfo&state=123"];
//    [self.navigationController pushViewController:web animated:YES];
//    [self presentViewController:web animated:true completion:nil];
    
//    [self readFile];
}

- (IBAction)saveQRImage:(id)sender {
    UIImage *qrImage = self.qrImageView.image;
    if (qrImage) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage: qrImage];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
        }];
    }
}
- (IBAction)refreshQRCode:(id)sender {
    if (self.paramDic) {
        [self getQRCodeWithParam:self.paramDic];
    } else {
        [self alert:@"您还未操作过授权登录" message:@"请到需要授权的APP里面，点击微信授权登录" handler:nil];
    }
}

-(void)loadQRCodeImg:(NSString *)url{
    
    //1.将字符串转出NSData
    NSData *img_data = [url dataUsingEncoding:NSUTF8StringEncoding];
    
    //2.将字符串变成二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //  条形码 filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    
    //3.恢复滤镜的默认属性
    [filter setDefaults];
    
    //4.设置滤镜的 inputMessage
    [filter setValue:img_data forKey:@"inputMessage"];
    
    //5.获得滤镜输出的图像
    CIImage *img_CIImage = [filter outputImage];
    
    //6.此时获得的二维码图片比较模糊，通过下面函数转换成高清
    self.qrImageView.image = [self changeImageSizeWithCIImage:img_CIImage andSize:300];
}

- (UIImage *)changeImageSizeWithCIImage:(CIImage *)ciImage andSize:(CGFloat)size{
    CGRect extent = CGRectIntegral(ciImage.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:ciImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
}

- (void)getQRCodeWithParam:(NSDictionary *)param {
    [SVProgressHUD showWithStatus:@"获取二维码中"]; // 魔力转圈圈
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSString *qrconnect = @"/connect/app/qrconnect";
//    NSString *urlStr = [NSString stringWithFormat:@"%@%@", base, qrconnect];
    manager.requestSerializer = [AFHTTPRequestSerializer new];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"zh-cn" forHTTPHeaderField:@"Accept-Language"];
    [manager.requestSerializer setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/7.0.0(0x17000024) NetType/WIFI Language/zh_CN" forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:@"https://open.weixin.qq.com/connect/app/qrconnect?appid=wxeb02111ffac292ae&bundleid=com.dangbeiyingshishequ.www&scope=snsapi_userinfo&state=xxx" forKey:@"referer"];
    [manager GET:@"https://open.weixin.qq.com/connect/confirm?uuid=081AoC2c2ycIxlFt" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        NSString * str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *uuid = [[[str componentsSeparatedByString:@"uuid: "][1] componentsSeparatedByString:@","][0] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *authName = [[str componentsSeparatedByString:@"<strong class=\"auth_nickname\">"][1] componentsSeparatedByString: @"</strong>"][0];
        self.titleLabel.text = authName;
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        NSString *qrCodeUrl = [NSString stringWithFormat:@"%@/connect/qrcode/%@", base, uuid];
        NSString *origin = [[[task currentRequest] URL] absoluteString];
        [self downloadQRImageWithURL:qrCodeUrl originURL:origin];
        [self getAuthResultWithUUID:uuid origin:origin];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss]; // 取消转圈圈
        [self alert:@"获取二维码失败" message:[error localizedDescription] handler:nil];
    }];
    
}

- (void)alert:(NSString*) title message:(NSString*) message handler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:handler];
    [alertCtrl addAction:action];
    [self presentViewController:alertCtrl animated:true completion:nil];
}


- (void)downloadQRImageWithURL:(NSString *)url originURL:(NSString *)origin {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer new];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"zh-cn" forHTTPHeaderField:@"Accept-Language"];
    [manager.requestSerializer setValue:origin forHTTPHeaderField:@"Referer"];
    [manager.requestSerializer setValue:@"image/png,image/svg+xml,image/*;q=0.8,video/*;q=0.8,*/*;q=0.5" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/7.0.0(0x17000024) NetType/WIFI Language/zh_CN" forHTTPHeaderField:@"User-Agent"];
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        if ([UIImage imageWithData:responseObject]) {
            UIImage *image = [UIImage imageWithData:responseObject];
            self.qrImageView.image = image;
        } else {
            [self alert:@"获取二维码" message:@"获取二维码失败, 请重试\n" handler:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self alert:@"获取二维码" message:[@"获取二维码失败, 请重试\n" stringByAppendingString:[error localizedDescription]] handler:nil];
    }];
}

- (void)getAuthResultWithUUID:(NSString *)uuid origin:(NSString *)origin {
    self.tipsLabel.hidden = YES;
    NSString *currentDate = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970]*1000)];
    //    NSDictionary *paramDic = @{@"uuid": uuid, @"f": @"url", @"_": currentDate};
    NSString *baseURL = @"https://long.open.weixin.qq.com/connect/l/qrconnect";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer new];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"zh-cn" forHTTPHeaderField:@"Accept-Language"];
    [manager.requestSerializer setValue:origin forHTTPHeaderField:@"Referer"];
    [manager.requestSerializer setValue:@"image/png,image/svg+xml,image/*;q=0.8,video/*;q=0.8,*/*;q=0.5" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 12_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/7.0.0(0x17000024) NetType/WIFI Language/zh_CN" forHTTPHeaderField:@"User-Agent"];
    NSString *url = [NSString stringWithFormat:@"%@?uuid=%@&f=url&_=%@", baseURL, uuid, currentDate];
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *wx_errcode = [[str componentsSeparatedByString:@";"][0] componentsSeparatedByString:@"="][1];
        NSString *wx_redirecturl = [[str componentsSeparatedByString:@";"][1] componentsSeparatedByString:@"='"][1];
        NSString *wx_nickname = [[str componentsSeparatedByString:@";"][2] componentsSeparatedByString:@"="][1];
        if (![wx_errcode isEqualToString:@"405"]) {
            [self getAuthResultWithUUID:uuid origin:origin];
        } else {
            //授权成功，打开app
            self.tipsLabel.text = [NSString stringWithFormat:@"%@ 授权成功\n跳转中...", wx_nickname];
            self.tipsLabel.hidden = NO;
            NSURL *url = [NSURL URLWithString: [wx_redirecturl stringByReplacingOccurrencesOfString:@"'" withString:@""]];
            [[UIApplication sharedApplication] openURL:url];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self getAuthResultWithUUID:uuid origin:origin];
        NSLog(@"获取授权码失败, 请重试\n %@", [error localizedDescription]);
    }];
}

/*
- (void)readFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"account" ofType:@"txt"];
    NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *array = [content componentsSeparatedByString:@"\n"];
    NSString *origin = [[NSBundle mainBundle] pathForResource:@"account" ofType:@"sqlite"];
    NSString *desPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"account.sqlite"];
    [self moveItemAtPath:origin toPath:desPath error:nil];
    JQFMDB *db = [JQFMDB shareDatabase:@"account.sqlite"];
//    [db jq_createTable:@"user" dicOrModel:@{@"account":@"TEXT"}];
    
//    for (NSString *account in array) {
//        NSString *accountMD5 = [self getmd5WithString:account];
//        [db jq_insertTable:@"user" dicOrModel:@{@"account": accountMD5}];
//    }
    NSArray *personArr = [db jq_lookupTable:@"user" dicOrModel:@{@"account":@"TEXT"} whereFormat:@"where account = 'bd14e58a6f99604512dd671cc1616a65'"];
//    NSArray *personArr = [db jq_lookupTable:@"user" dicOrModel:@{@"account":@"TEXT"} whereFormat:nil];
    NSLog(@"表中所有数据:%@", personArr);
    
    
//    NSLog(@"存储完毕");
    
//    NSLog(@"path %@", path);
}



- (NSString*)getmd5WithString:(NSString *)string
{
    const char* original_str=[string UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    CC_MD5(original_str, (uint)strlen(original_str), digist);
    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [outPutStr appendFormat:@"%02x", digist[i]];//小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
    }
    return [outPutStr lowercaseString];
}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
}

- (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError *__autoreleasing *)error {
    // 先要保证源文件路径存在，不然抛出异常
    if (![self isExistsAtPath:path]) {
        [NSException raise:@"非法的源文件路径" format:@"源文件路径%@不存在，请检查源文件路径", path];
        return NO;
    }

    // 判断目标路径文件是否存在
    if ([self isExistsAtPath:toPath]) {
        //如果覆盖，删除目标路径文件
        [self removeItemAtPath:toPath error:error];
    }
    
    // 移动文件，当要移动到的文件路径文件存在，会移动失败
    BOOL isSuccess = [[NSFileManager defaultManager] moveItemAtPath:path toPath:toPath error:error];
    
    return isSuccess;
}

- (BOOL)createDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    * createDirectoryAtPath:withIntermediateDirectories:attributes:error:
     * 参数1：创建的文件夹的路径
     * 参数2：是否创建媒介的布尔值，一般为YES
     * 参数3: 属性，没有就置为nil
     * 参数4: 错误信息
     */
//    BOOL isSuccess = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
//    return isSuccess;
//}


/*

- (BOOL)isExistsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

*/


@end
