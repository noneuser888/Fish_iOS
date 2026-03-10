//
//  HomeProjectCell.m
//

#import "HomeProjectCell.h"

@interface HomeProjectCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLab;


@end

@implementation HomeProjectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(NSDictionary *)model {
    self.titleLab.text = model[@"title"];
    self.subTitleLab.text = model[@"subTitle"];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString: model[@"imageUrl"]] placeholderImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#D8D8D8"]]];
}

@end
