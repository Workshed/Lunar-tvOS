//
//  SFRAlbumHeaderCollectionReusableView.h
//  Apollo
//
//  Created by Daniel Leivers on 12/10/2015.
//  Copyright © 2015 Daniel Leivers. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFRAlbumHeaderDelegate <NSObject>

@required
- (void)startSlideShow;

@end

@interface SFRAlbumHeaderCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) id<SFRAlbumHeaderDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *slideShowButton;
@property (weak, nonatomic) IBOutlet UILabel *albumTitleLabel;

@end
