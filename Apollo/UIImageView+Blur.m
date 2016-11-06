//
//  UIImageView+Blur.m
//  Apollo
//
//  Created by Daniel Leivers on 05/11/2016.
//  Copyright © 2016 Daniel Leivers. All rights reserved.
//

#import "UIImageView+Blur.h"

@implementation UIImageView (Blur)

- (void)blurImageWithAlpha:(CGFloat)alpha {
    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    [effectView setContentMode:self.contentMode];
    [self addSubview:effectView];
    
    [effectView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-0-[effectView]-0-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(effectView)]];
    
    [self addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-0-[effectView]-0-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(effectView)]];
    [self layoutIfNeeded];
    [effectView setAlpha:alpha];
}

- (void)blurImage {
    [self blurImageWithAlpha:1.0];
}

@end
