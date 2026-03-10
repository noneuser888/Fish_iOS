//
//  AuthRecordCell.h
//  星途
//
//  Created by  on 2020/2/26.
//  
//

#import <UIKit/UIKit.h>
#import "AuthRecordVC.h"

@interface AuthRecordCell : UITableViewCell

@property (nonatomic, strong) void(^applyAfterSaleBlock)(void);

- (void)setData:(NSDictionary *)data;

@end

