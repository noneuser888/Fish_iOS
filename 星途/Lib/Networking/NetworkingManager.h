//
//  NetworkingManager.h
//  星途
//
//  Created by  on 2020/2/24.
//  
//

#import <Foundation/Foundation.h>
@class NetworkingManager;

typedef void(^Success)(id json);

typedef void(^Failure)(NSError *error);

typedef void (^HttpProgress)(NSProgress *progress);
//downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock

@interface NetworkingManager : NSObject

+(NetworkingManager *)manager;

-(void)getDataWithUrl:(NSString *)url
           parameters:(NSDictionary *)parameters
              success:(Success)success
              failure:(Failure)failure;


-(void)postDataWithUrl:(NSString *)url
            parameters:(NSDictionary *)parameters
               success:(Success)success failure:(Failure)failure;


/**
 *  上传单/多张图片
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param name       图片对应服务器上的字段
 *  @param images     图片数组
 *  @param fileNames  图片文件名数组, 可以为nil, 数组内的文件名默认为当前日期时间"yyyyMMddHHmmss"
 *  @param imageType  图片文件的类型,例:png、jpg(默认类型)....
 *  @param progress   上传进度信息
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 */
- (void)uploadImagesWithURL:(NSString *)URL
                 parameters:(NSDictionary *)parameters
                       name:(NSString *)name
                     images:(NSArray *)images
                  fileNames:(NSArray *)fileNames
                  imageType:(NSString *)imageType
                   progress:(HttpProgress)progress
                    success:(Success)success
                    failure:(Failure)failure;

@end

