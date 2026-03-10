//
//  HairlineConstraint.m
//  星途
//
//  Created by  on 2020/3/14.
//  
//

#import "HairlineConstraint.h"

@implementation HairlineConstraint

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.constant = 1.0 / [UIScreen mainScreen].scale;
}

@end
