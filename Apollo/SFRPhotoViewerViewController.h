//
//  SFRPhotoViewerViewController.h
//  Apollo
//
//  Created by Daniel Leivers on 11/10/2015.
//  Copyright © 2015 Daniel Leivers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFRPhotoViewerViewController : UIViewController

@property (strong, nonatomic) NSArray *imagesArray;
@property (assign, nonatomic) NSInteger currentPosition;
@property (strong, nonatomic) UIImage *previewImage;

@end
