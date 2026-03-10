//
//  AdManager.m
//  星途
//
//  Created by  on 2020/2/26.
//  
//

#import "AdManager.h"
static AdManager *shareManager = nil;

@interface AdManager()<SDWebImagePrefetcherDelegate>

@property (nonatomic, strong) NSArray *dataSource;
 
@end

@implementation AdManager

+ (AdManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[AdManager alloc] init];
    });
    return shareManager;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSArray alloc] init];
    }
    return _dataSource;
}

- (void)checkLaunchAd {
    NSString *url = [NSString stringWithFormat:@"%@/launchAd", baseUrl];
    [[NetworkingManager manager] getDataWithUrl:url parameters:nil success:^(id json) {
        NSDictionary *data = json[@"data"];
        NSArray *imageList = data[@"imgList"];
        if (imageList && imageList.count > 0) {
            //            NSArray *tmp = @[@{@"webLink": @"https://www.baidu.com", @"imgUrl": @"http://img5.imgtn.bdimg.com/it/u=1532903649,567852392&fm=15&gp=0.jpg"},
            //            @{@"webLink": @"https://www.baidu.com", @"imgUrl": @"http://img4.imgtn.bdimg.com/it/u=4266957624,532175474&fm=15&gp=0.jpg"}];
            [self saveLauchAds:imageList];
        } else {
            [self clearCache];
            return;
        }
    } failure:nil];
}

- (void)clearCache {
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"LaunchAds"]) {
        NSArray *ads = [[NSUserDefaults standardUserDefaults] valueForKey:@"LaunchAds"];
        for (NSDictionary *ad in ads) {
            NSString *imageUrl = ad[@"imgUrl"];
            if (imageUrl) {
                NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:imageUrl]];
                [[SDImageCache sharedImageCache] removeImageForKey:key withCompletion:nil];
            }
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LaunchAds"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)saveLauchAds:(NSArray *)imageList {
    self.dataSource = imageList;
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in imageList) {
        [imageArray addObject: [NSURL URLWithString:dic[@"imgUrl"]]];
    }
    SDWebImagePrefetcher *prefetcher = [SDWebImagePrefetcher sharedImagePrefetcher];
    prefetcher.delegate = self;
    [prefetcher prefetchURLs: imageArray
                    progress:nil
                   completed:nil];
}

- (void)imagePrefetcher:(nonnull SDWebImagePrefetcher *)imagePrefetcher didFinishWithTotalCount:(NSUInteger)totalCount skippedCount:(NSUInteger)skippedCount {
    [[NSUserDefaults standardUserDefaults] setObject:self.dataSource forKey:@"LaunchAds"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"下载完成 totalCount: %ld   skippedCount: %ld", totalCount, skippedCount);
}


@end
