//
//  SFRPhotoViewerViewController.m
//  Apollo
//
//  Created by Daniel Leivers on 11/10/2015.
//  Copyright © 2015 Daniel Leivers. All rights reserved.
//

#import "SFRPhotoViewerViewController.h"
#import "UIImageView+AFNetworking.h"
#import "SFRConstants.h"
#import "UIImageView+Blur.h"

@interface SFRPhotoViewerViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIImageView *mainImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;
@property (nonatomic) CGFloat lastZoomScale;

@property (assign, nonatomic) BOOL isZoomed;

@end

@implementation SFRPhotoViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.scrollView.panGestureRecognizer.allowedTouchTypes = [NSArray arrayWithObjects:[NSNumber numberWithInteger:UITouchTypeIndirect], nil];
    [self setupBackground];
    [self loadPhoto];
}

- (void)setupBackground {
    self.backgroundImageView.image = nil;
    
    if (self.previewImage) {
        [self.backgroundImageView setImage:self.previewImage];
        [self.backgroundImageView blurImage];
    }
}

- (void)reloadBackground {
    NSDictionary *photoDict = [self.imagesArray objectAtIndex:self.currentPosition];
    if (photoDict[kUrlKey]) {
        NSString *urlString = photoDict[kUrlKey];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        __weak SFRPhotoViewerViewController *weakSelf = self;
        [self.backgroundImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
            weakSelf.previewImage = image;
            [weakSelf setupBackground];
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            weakSelf.previewImage = nil;
            [weakSelf setupBackground];
        }];
    }
}

- (void)loadPhoto {
    NSDictionary *photoDict = [self.imagesArray objectAtIndex:self.currentPosition];
    [self.scrollView setUserInteractionEnabled:NO];
    self.isZoomed = YES;
    if (photoDict[@"url_o"]) {
        NSString *urlString = photoDict[@"url_o"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        __weak SFRPhotoViewerViewController *weakSelf = self;
        [self.mainImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
            [weakSelf.mainImageView setImage:image];
            [weakSelf resetZoom];
            weakSelf.isZoomed = NO;
            [weakSelf.scrollView setUserInteractionEnabled:YES];
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (IBAction)clicked:(id)sender {
    static float zoomLevels = 3.0;
    float newZoomScale = self.scrollView.zoomScale + ((self.scrollView.maximumZoomScale - self.scrollView.minimumZoomScale) / zoomLevels);
    self.isZoomed = YES;
    if (newZoomScale > self.scrollView.maximumZoomScale) {
        if (self.scrollView.zoomScale < self.scrollView.maximumZoomScale) {
            newZoomScale = self.scrollView.maximumZoomScale;
        }
        else {
            newZoomScale = self.scrollView.minimumZoomScale;
            self.isZoomed = NO;
        }
    }

    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (IBAction)swiped:(UISwipeGestureRecognizer *)swipeGesture {
    if (!self.isZoomed) {
        if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
            if (self.currentPosition > 0) {
                self.currentPosition--;
            }
            else {
                self.currentPosition = self.imagesArray.count - 1;
            }
            
            [self reloadBackground];
            [self loadPhoto];
        }
        else if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
            if (self.currentPosition < self.imagesArray.count - 1) {
                self.currentPosition++;
            }
            else {
                self.currentPosition = 0;
            }
            
            [self reloadBackground];
            [self loadPhoto];
        }
    }
}

#pragma mark - UIScrollViewDelegate methods


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.mainImageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateConstraintsForZoomOrScroll];
}

- (void) scrollViewDidZoom:(UIScrollView *)scrollView {
    [self updateConstraintsForZoomOrScroll];
}

#pragma mark Handle zooming and panning

- (void)updateConstraintsForZoomOrScroll {
    float imageWidth = self.mainImageView.image.size.width;
    float imageHeight = self.mainImageView.image.size.height;
    
    float viewWidth = self.view.bounds.size.width;
    float viewHeight = self.view.bounds.size.height;
    
    // center image if it is smaller than screen
    float hPadding = (viewWidth - self.scrollView.zoomScale * imageWidth) / 2;
    if (hPadding < 0) {
        hPadding = 0;
    }
    
    float vPadding = (viewHeight - self.scrollView.zoomScale * imageHeight) / 2;
    if (vPadding < 0) {
        vPadding = 0;
    }
    
    self.constraintLeft.constant = hPadding;
    self.constraintRight.constant = hPadding;
    
    self.constraintTop.constant = vPadding;
    self.constraintBottom.constant = vPadding;
    
    // Makes zoom out animation smooth and starting from the right point not from (0, 0)
    [self.view layoutIfNeeded];
}

/** Zoom to show as much image as possible unless image is smaller than screen */
- (void)resetZoom {
    float minZoom = MIN(self.view.bounds.size.width / self.mainImageView.image.size.width,
                        self.view.bounds.size.height / self.mainImageView.image.size.height);
    
    if (minZoom > 1) {
        minZoom = 1;
    }
    
    self.scrollView.minimumZoomScale = minZoom;
    
    // Force scrollViewDidZoom fire if zoom did not change
    if (minZoom == self.lastZoomScale) {
        minZoom += 0.000001;
    }
    
    self.lastZoomScale = self.scrollView.zoomScale = minZoom;
}

@end
