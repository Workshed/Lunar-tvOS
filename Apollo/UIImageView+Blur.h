//
//  UIImageView+Blur.h
//  Apollo
//
//  Created by Daniel Leivers on 05/11/2016.
//  Copyright © 2016 Daniel Leivers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Blur)

- (void)blurImageWithAlpha:(CGFloat)alpha;
- (void)blurImage;

@end
