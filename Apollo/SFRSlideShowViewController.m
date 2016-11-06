//
//  SFRSlideShowViewController.m
//  Apollo
//
//  Created by Daniel Leivers on 13/10/2015.
//  Copyright © 2015 Daniel Leivers. All rights reserved.
//

#import "SFRSlideShowViewController.h"
#import "UIImageView+AFNetworking.h"
#import "SFRPhotoViewerViewController.h"
#import "UIImageView+Blur.h"

@interface SFRSlideShowViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pauseMenuViewVerticalCentre;
@property (weak, nonatomic) IBOutlet UIView *pauseMenuView;
@property (weak, nonatomic) IBOutlet UIImageView *pauseMenuBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (weak, nonatomic) IBOutlet UIButton *exploreButton;
@property (weak, nonatomic) IBOutlet UIButton *speedUpButton;
@property (weak, nonatomic) IBOutlet UIButton *speedDownButton;
@property (weak, nonatomic) IBOutlet UILabel *currentSpeedLabel;

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *pauseMenuGesture;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *pauseMenuTriggerGesture;

@property (weak, nonatomic) UIImageView *currentImageView;
@property (assign, nonatomic) NSInteger currentPosition;
@property (strong, nonatomic) NSTimer *slideTimer;

@property (assign, nonatomic) float slideDuration;

@end

@implementation SFRSlideShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.pauseMenuGesture setEnabled:NO];
    self.slideDuration = 3.0;
    [self updateDurationLabel];
    self.currentImageView = self.imageView2;
    [self loadNextPhoto];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.slideTimer) {
        [self.slideTimer invalidate];
    }
}

- (UIImageView * _Nullable)nextImageView {
    UIImageView *imageView = nil;
    if (self.currentImageView == self.imageView1) {
        imageView = self.imageView2;
    }
    else if (self.currentImageView == self.imageView2) {
        imageView = self.imageView1;
    }
    
    return imageView;
}

- (void)loadNextPhoto {
    if (self.currentPosition >= self.imagesArray.count) {
        self.currentPosition = 0;
    }
    
    NSDictionary *photoDict = [self.imagesArray objectAtIndex:self.currentPosition];
    if (photoDict[@"url_o"]) {
        UIImageView *nextImageView = [self nextImageView];
        if (nextImageView) {
            [nextImageView setImage:nil];
            NSString *urlString = photoDict[@"url_o"];
            NSURL *url = [NSURL URLWithString:urlString];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            __weak SFRSlideShowViewController *weakSelf = self;
            [nextImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                [[weakSelf nextImageView] setImage:image];
                [weakSelf transitionToNextPhoto];
                weakSelf.currentPosition++;
                weakSelf.currentImageView = [weakSelf nextImageView];
                [weakSelf setupPauseBackground];
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }
}

- (void)transitionToNextPhoto {
    UIImageView *nextImageView = [self nextImageView];
    if (nextImageView) {
        [self.pauseMenuTriggerGesture setEnabled:NO];
        [nextImageView setAlpha:0.0];
        [self.view bringSubviewToFront:nextImageView];
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            nextImageView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [self.pauseMenuTriggerGesture setEnabled:YES];
            [self startTimer];
        }];
    }
}

- (void)startTimer {
    if (self.slideTimer) {
        [self.slideTimer invalidate];
    }
    self.slideTimer = [NSTimer scheduledTimerWithTimeInterval:self.slideDuration target:self selector:@selector(loadNextPhoto) userInfo:nil repeats:NO];
}

- (void)setupPauseBackground {
    
    self.pauseMenuBackgroundView.image = nil;
    
    if (self.currentImageView && self.currentImageView.image) {
        [self.pauseMenuBackgroundView setImage:self.currentImageView.image];
        NSArray<UIView *> *subviews = [self.pauseMenuBackgroundView subviews];
        for (UIView *view in subviews) {
            [view removeFromSuperview];
        }
        
        [self.pauseMenuBackgroundView blurImage];
    }
}

- (IBAction)pauseResumeSlideShow:(id)sender {
    if ([self.pauseMenuView isHidden]) {
        if (self.slideTimer) {
            [self.slideTimer invalidate];
        }
        // Show it...
        [self showPauseMenu];
    }
    else {
        [self hidePauseMenu];
    }
}

- (void)showPauseMenu {
    // Cancel any impending image changes
    [self.currentImageView cancelImageDownloadTask];
    [[self nextImageView] cancelImageDownloadTask];
    
    // Set up UI
    [self.pauseMenuView setAlpha:0.0];
    [self.pauseMenuView setHidden:NO];
    [self.view bringSubviewToFront:self.pauseMenuView];
    [self.pauseMenuViewVerticalCentre setConstant:-self.view.bounds.size.height];
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.pauseMenuView setAlpha:1.0];
    } completion:^(BOOL finished) {
        [self.pauseMenuViewVerticalCentre setConstant:0.0];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.pauseMenuGesture setEnabled:YES];
            [self.resumeButton setNeedsFocusUpdate];
        }];
    }];
}

- (void)hidePauseMenu {
    [self.pauseMenuViewVerticalCentre setConstant:+self.view.bounds.size.height];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.pauseMenuView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [self.pauseMenuGesture setEnabled:NO];
            [self.pauseMenuView setHidden:YES];
            [self startTimer];
        }];
    }];
}

#pragma mark - Pause button handling

- (IBAction)resumeButtonPressed:(id)sender {
    [self pauseResumeSlideShow:sender];
}

- (IBAction)exploreButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"explorePhoto" sender:self];
}

- (IBAction)speedUpButtonPressed:(id)sender {
    self.slideDuration -= 0.5;
    if (self.slideDuration < 0.5) {
        self.slideDuration = 0.5;
    }
    [self updateDurationLabel];
}

- (IBAction)speedDownButtonPressed:(id)sender {
    self.slideDuration += 0.5;
    [self updateDurationLabel];
}

- (void)updateDurationLabel {
    [self.currentSpeedLabel setText:[NSString stringWithFormat:@"%.1fs", self.slideDuration]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"explorePhoto"]) {
        SFRPhotoViewerViewController *photoViewer = segue.destinationViewController;
        [photoViewer setImagesArray:self.imagesArray];
        [photoViewer setCurrentPosition:self.currentPosition - 1];
        [photoViewer setPreviewImage:self.currentImageView.image];
    }
}

@end
