//
//  UISearchBar+App.m
//

#import "UISearchBar+App.h"

@implementation UISearchBar (App)

- (void)setFont:(CGFloat)size {
    UITextField *searchTextField = nil;
    for (UIView *view in [self.subviews firstObject].subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            searchTextField = (UITextField *)view;
            break;
        }
    }
    if (searchTextField) {
        searchTextField.font = [UIFont systemFontOfSize:size];
        searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:searchTextField.placeholder.length > 0 ? searchTextField.placeholder : @""
                                                                                attributes:@{NSFontAttributeName : [UIFont fontWithName:@"futura" size:size]}];
    }
}

@end
