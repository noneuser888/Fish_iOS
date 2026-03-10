//
//  PopMenuCell.m
//

#import "PopMenuCell.h"

@interface PopMenuCell()


@end

@implementation PopMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubViewsProperties];
    }
    return self;
}

- (void)setupSubViewsProperties {
    self.iconImageView                                           = [[UIImageView alloc] init];
    self.iconImageView.contentMode                               = UIViewContentModeScaleAspectFit;
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.iconImageView];

    self.titleLabel                                              = [[UILabel alloc] init];
    self.titleLabel.font                                         = [UIFont systemFontOfSize:15];
    self.titleLabel.textColor                                    = [UIColor blackColor];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints    = NO;
    [self.contentView addSubview:self.titleLabel];
}

- (void)setShowType:(PopMenuType)showType {
    _showType = showType;
    [self setupSubViewsConstraint];
}

- (void)setTitleLabel:(UILabel *)titleLabel {
    _titleLabel = titleLabel;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setupSubViewsConstraint {
    if (self.showType == PopMenuTypeNormal) {
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        
        [self.contentView addConstraints:@[
                                           [NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:15],
                                           [NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
                                           ]];
        
        [self.contentView addConstraints:@[
                                           [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.iconImageView attribute:NSLayoutAttributeTrailing multiplier:1 constant:10],
                                           [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
                                           ]];
    } else if (self.showType == PopMenuTypeOnlyTitle){
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addConstraints:@[
                                           [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
                                           [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
                                           ]];
    } else {
        [self.contentView addConstraints:@[
                                           [NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0],
                                           [NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0],
                                           ]];
    }
}

@end
