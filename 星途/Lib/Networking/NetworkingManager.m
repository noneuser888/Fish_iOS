//
//  NetworkingManager.m
//  星途
//
//  Created by  on 2020/2/24.
//  
//

#import "NetworkingManager.h"

static NetworkingManager *manager = nil;
static AFHTTPSessionManager *afnManager = nil;

//static dispatch_queue_t dispatchQueue = nil;

@interface NetworkingManager()

{
    AFHTTPSessionManager *_sessionManager;
    dispatch_queue_t dispatchQueue;
}

@end

@implementation NetworkingManager

- (instancetype)init {
    self = [super init];
    dispatchQueue = dispatch_queue_create("com.ywxskj.NetworkingManager",DISPATCH_QUEUE_CONCURRENT);
    return self;
}

+ (NetworkingManager *)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NetworkingManager alloc] init];
    });
    return manager;
}

+ (UIViewController *)currentVC {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC;
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        currentVC = ((UINavigationController *)rootVC).visibleViewController;
    } else {
        currentVC = rootVC;
    }
    return currentVC;
}

+ (void)alert:(NSString*)title message:(NSString*) message handler:(void (^ __nullable)(UIAlertAction *action))handler {
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:handler];
    [alertCtrl addAction:action];
    [[NetworkingManager currentVC] presentViewController:alertCtrl animated:YES completion:nil];
}

- (void)getDataWithUrl:(NSString *)url
            parameters:(NSDictionary *)parameters
               success:(Success)success
               failure:(Failure)failure {
    [self requestMethod:@"GET"
                    url:url
             parameters:parameters
                request:nil
         uploadProgress:nil
       downloadProgress:nil
                success:success
                failure:failure];
}

- (void)postDataWithUrl:(NSString *)url
             parameters:(NSDictionary *)parameters
                success:(Success)success
                failure:(Failure)failure {
    [self requestMethod:@"POST"
                    url:url
             parameters:parameters
                request:nil
         uploadProgress:nil
       downloadProgress:nil
                success:success
                failure:failure];
}

- (void)uploadImagesWithURL:(NSString *)URL
                 parameters:(NSDictionary *)parameters
                       name:(NSString *)name
                     images:(NSArray *)images
                  fileNames:(NSArray *)fileNames
                  imageType:(NSString *)imageType
                   progress:(HttpProgress)progress
                    success:(Success)success
                    failure:(Failure)failure {
    [_sessionManager.requestSerializer setValue:currentVersion forHTTPHeaderField:@"version"];
    [_sessionManager.requestSerializer setValue:[[NSBundle mainBundle] bundleIdentifier] forHTTPHeaderField:@"bundleIdentifier"];
    [_sessionManager.requestSerializer setValue:@"1" forHTTPHeaderField:@"device"];
    if ([[UserInfoModel shared] isLogin]) {
        [_sessionManager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer%@", [[UserInfoModel shared] loginToken]] forHTTPHeaderField:@"Authorization"];
    }
    dispatch_queue_t current_queue_t = nil;
    if ([[NSOperationQueue currentQueue] respondsToSelector:@selector(underlyingQueue)]) {
        current_queue_t = [NSOperationQueue currentQueue].underlyingQueue;
    } else {
        current_queue_t = dispatch_get_main_queue();
    }
    NSURLSessionTask *sessionTask = [_sessionManager POST:URL parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSUInteger i = 0; i < images.count; i++) {
            // 图片经过等比压缩后得到的二进制文件
            NSData *imageData = UIImageJPEGRepresentation(images[i], 1.f);
            // 默认图片的文件名, 若fileNames为nil就使用
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *imageFileName = [NSString stringWithFormat:@"%@%ld.%@",str,i,imageType?:@"jpg"];
            [formData appendPartWithFileData:imageData
                                        name:name
                                    fileName:fileNames ? [NSString stringWithFormat:@"%@.%@",fileNames[i],imageType?:@"jpg"] : imageFileName
                                    mimeType: [NSString stringWithFormat:@"image/%@",imageType ?: @"jpg"]];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(uploadProgress) : nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(current_queue_t, ^{
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            NSString *code = [NSString stringWithFormat:@"%@", dict[@"code"]];
            if ([code isEqualToString:@"20000"]) {
                if (success) {
                    success(dict);
                }
            } else {
                NSString *message = [NSString nullToString:dict[@"message"]];
                if ([message isEqualToString:@""]) {
                    message = @"服务器更新，请稍后重试";
                }
                NSError *error = [[NSError alloc] initWithDomain:message code:[code integerValue] userInfo:nil];
                if (failure){
                    failure(error);
                }
                [SVProgressHUD showErrorWithStatus:message];
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString *message;
        if (![AFNetworkReachabilityManager sharedManager].isReachable) {
            message = @"似乎已断开与互联网的连接。";
        } else {
            message = @"服务器更新，请稍后重试";
        }
        NSError *tmpError = [[NSError alloc] initWithDomain:message code:0 userInfo:nil];
        if (failure){
            failure(tmpError);
        }
        [SVProgressHUD showErrorWithStatus:message];
    }];
    [sessionTask resume];
    
}


- (void)requestMethod:(NSString *)method
                  url:(NSString *)url
           parameters:(NSDictionary *)parameters
              request:(nullable NSMutableURLRequest *)request
       uploadProgress:(HttpProgress)uploadProgressBlock
     downloadProgress:(HttpProgress)downloadProgressBlock
              success:(Success)success
              failure:(Failure)failure {
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    requestSerializer.timeoutInterval = 30;
    requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSMutableURLRequest *tmpRequest = request ?: [[AFJSONRequestSerializer serializer]
                                                  requestWithMethod:method
                                                  URLString:url
                                                  parameters:parameters
                                                  error:nil];
    [tmpRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [tmpRequest setValue:currentVersion forHTTPHeaderField:@"version"];
    [tmpRequest setValue:[[NSBundle mainBundle] bundleIdentifier] forHTTPHeaderField:@"bundleIdentifier"];
    [tmpRequest setValue:@"1" forHTTPHeaderField:@"device"];
    [tmpRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if ([[UserInfoModel shared] isLogin] || [url hasSuffix:@"idCardVerify"]) {
        [tmpRequest setValue:[NSString stringWithFormat:@"Bearer%@", [[UserInfoModel shared] loginToken]] forHTTPHeaderField:@"Authorization"];
    }
    //    else {
    //        [request setValue:@"" forHTTPHeaderField:@"Authorization"];
    ////        [afnManager.requestSerializer setValue: @"" forHTTPHeaderField:@"Authorization"];
    //    }
    dispatch_queue_t current_queue_t = nil;
    if ([[NSOperationQueue currentQueue] respondsToSelector:@selector(underlyingQueue)]) {
        current_queue_t = [NSOperationQueue currentQueue].underlyingQueue;
    } else {
        current_queue_t = dispatch_get_main_queue();
    }
    NSURLSessionDataTask *task = [self.sessionManager
                                  dataTaskWithRequest:tmpRequest
                                  uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            //            if (up)
            uploadProgressBlock ? uploadProgressBlock(uploadProgress) : nil;
        });
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            downloadProgressBlock ? downloadProgressBlock(downloadProgress) : nil;
        });
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        dispatch_async(current_queue_t, ^{
            NSDictionary *result;
            if (responseObject) {
                result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            }
#if defined(DEBUG)||defined(_DEBUG)
            NSLog(@"请求：%@\n%@", url, parameters);
            if (result) {
                NSLog(@"结果：%@", result);
            } else {
                NSLog(@"结果：%@", responseObject);
            }
#endif
            if (error == nil) {
                NSString *code = [NSString stringWithFormat:@"%@", result[@"code"]];
                if ([code isEqualToString:@"20000"]) {
                    if (success) {
                        success(result);
                    }
                } else {
                    NSString *message = [NSString nullToString:result[@"message"]];
                    if ([message isEqualToString:@""]) {
                        message = @"服务器更新，请稍后重试";
                    } else if ([code isEqualToString:@"20003"]) {
                        message = @"登录过期，请重新登录";
                        [[UserInfoModel shared] setLogin:NO];
                    } else {
                        NSError *error = [[NSError alloc] initWithDomain:message code:[code integerValue] userInfo:nil];
                        if (failure){
                            failure(error);
                        }
                    }
                    [SVProgressHUD showErrorWithStatus:message];
                }
            } else {
                NSString *message;
                NSString *status = [NSString stringWithFormat:@"%@", result[@"status"]];
                if ([status isEqualToString:@"403"]) {
                    message = @"登录过期，请重新登录";
                    [[UserInfoModel shared] setLogin:NO];
                } else if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
                    message = @"似乎已断开与互联网的连接。";
                } else {
                    message = @"服务器更新，请稍后重试";
                }
                NSError *error = [[NSError alloc] initWithDomain:message code:0 userInfo:nil];
                if (failure){
                    failure(error);
                }
                [SVProgressHUD showErrorWithStatus:message];
            }
        });
    }];
    
    [task resume];
}

- (void)alert:(NSString*)title message:(NSString*)message btnTitle:(NSString *)btnTitle cancelEnable:(BOOL)cancelEnable handler:(void (^ __nullable)(UIAlertAction *action))handler cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault handler:handler];
    [alertCtrl addAction:action];
    if (cancelEnable) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:cancelHandler];
        [alertCtrl addAction:cancel];
    }
    UIViewController *vc = [UIViewController getCurrentVC];
    [vc presentViewController:alertCtrl animated:YES completion:nil];
}

#pragma mark - getter & setter
- (AFURLSessionManager *)sessionManager{
    if (_sessionManager == nil) {
        
        const char *label = [baseUrl cStringUsingEncoding:NSUTF8StringEncoding];
        dispatch_queue_t completionQueue = dispatch_queue_create(label, DISPATCH_QUEUE_CONCURRENT);
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        if ([configServer isEqualToString:@"1"]) {
            if (![UserInfoModel isHTTPS]) {
                configuration.connectionProxyDictionary = @{};
            }
        }
        configuration.timeoutIntervalForRequest = 180;
        
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.securityPolicy.allowInvalidCertificates = NO;
        _sessionManager.securityPolicy.validatesDomainName = YES;
        _sessionManager.completionQueue = completionQueue;
        
    }
    return _sessionManager;
}

@end
