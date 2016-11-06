//
//  SFRAlbumHeaderCollectionReusableView.m
//  Apollo
//
//  Created by Daniel Leivers on 12/10/2015.
//  Copyright © 2015 Daniel Leivers. All rights reserved.
//

#import "SFRAlbumHeaderCollectionReusableView.h"

@implementation SFRAlbumHeaderCollectionReusableView

- (IBAction)pressedSlideShow:(id)sender {
    if (self.delegate) {
        [self.delegate startSlideShow];
    }
}

@end
