//
//  SFRAlbumViewController.m
//  Apollo
//
//  Created by Daniel Leivers on 11/10/2015.
//  Copyright © 2015 Daniel Leivers. All rights reserved.
//

#import "SFRAlbumViewController.h"
#import "SFRPhotoSetCollectionViewCell.h"
#import "FlickrKit.h"
#import "UIImageView+AFNetworking.h"
#import "SFRPhotoViewerViewController.h"
#import "SFRAlbumHeaderCollectionReusableView.h"
#import "SFRSlideShowViewController.h"
#import "SFRConstants.h"

#define COLLECTION_HEADER_HEIGHT 250

@interface SFRAlbumViewController () <SFRAlbumHeaderDelegate>

@property (strong, nonatomic) NSDictionary *albumInformation;
@property (strong, nonatomic) NSArray *imagesArray;

@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPhotosCollectionViewConstriant;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) UIButton *headerButton;
@property (weak, nonatomic) UILabel *albumTitleLabel;

@end

@implementation SFRAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadBackgroundImage];
    [self loadImageList];
}

- (void)loadBackgroundImage {
    if (self.albumDictionary[@"primary_photo_extras"][@"url_o"]) {
        NSString *urlString = self.albumDictionary[@"primary_photo_extras"][@"url_o"];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        __weak SFRAlbumViewController *weakSelf = self;
        [self.backgroundImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
            weakSelf.backgroundImageView.alpha = 0.0;
            [weakSelf.backgroundImageView setImage:image];
            [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.backgroundImageView.alpha = 1.0;
            } completion:^(BOOL finished) {
                
            }];
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
            // Failed image load - it's just the background image, if the main image fails we'll pop to the previous view controller
        }];
    }
}

- (void)loadImageList {
    [self.photosCollectionView setUserInteractionEnabled:NO];
    [self.photosCollectionView setHidden:YES];
    FKFlickrPhotosetsGetPhotos *photosList = [[FKFlickrPhotosetsGetPhotos alloc] init];
    [photosList setPhotoset_id:self.albumDictionary[@"id"]];
    [photosList setExtras:@"url_sq,url_t,url_s,url_m,url_o"];
    [[FlickrKit sharedFlickrKit] call:photosList maxCacheAge:FKDUMaxAgeOneDay completion:^(NSDictionary *response, NSError *error) {
        if (response && response[@"photoset"][@"photo"]) {
            self.albumInformation = response;
            self.imagesArray = response[@"photoset"][@"photo"];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.photosCollectionView reloadData];
                [self animateCollectionView];
            }];
        }
        else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }];
}

- (void)animateCollectionView {
    [self.topPhotosCollectionViewConstriant setConstant:self.view.bounds.size.height - COLLECTION_HEADER_HEIGHT];
    [self.view layoutIfNeeded];

    [self.headerButton setHidden:YES];
    [self.albumTitleLabel setHidden:YES];
    
    [self.photosCollectionView setHidden:NO];
    [self.topPhotosCollectionViewConstriant setConstant:0];

    [UIView animateWithDuration:0.8 delay:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.photosCollectionView setNeedsFocusUpdate];

        [self.headerButton setHidden:NO];
        [self.albumTitleLabel setHidden:NO];
        self.headerButton.alpha = 0.0;
        self.albumTitleLabel.alpha = 0.0;
        [self.photosCollectionView setUserInteractionEnabled:YES];
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.headerButton.alpha = 1.0;
            self.albumTitleLabel.alpha = 1.0;
        } completion:nil];
    }];
}

- (void)applyFocusWithContext:(UICollectionViewFocusUpdateContext *)context {
    SFRPhotoSetCollectionViewCell *cell = (SFRPhotoSetCollectionViewCell *)[self.photosCollectionView cellForItemAtIndexPath:context.nextFocusedIndexPath];
    [self.photosCollectionView bringSubviewToFront:cell];
    [cell.titleLabel setFont:[UIFont fontWithName:cell.titleLabel.font.fontName size:25.0]];
    
    if (context.previouslyFocusedIndexPath) {
        SFRPhotoSetCollectionViewCell *previousCell = (SFRPhotoSetCollectionViewCell *)[self.photosCollectionView cellForItemAtIndexPath:context.previouslyFocusedIndexPath];
        [previousCell.titleLabel setFont:[UIFont fontWithName:previousCell.titleLabel.font.fontName size:17.0]];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPhoto"]) {
        NSArray *selectedCells = [self.photosCollectionView indexPathsForSelectedItems];
        if (selectedCells.count > 0) {
            NSIndexPath *selectedPath = [selectedCells firstObject];
            SFRPhotoViewerViewController *photoViewer = segue.destinationViewController;
            [photoViewer setImagesArray:self.imagesArray];
            [photoViewer setCurrentPosition:selectedPath.row];
            SFRPhotoSetCollectionViewCell *cell = (SFRPhotoSetCollectionViewCell *)[self.photosCollectionView cellForItemAtIndexPath:selectedPath];
            [photoViewer setPreviewImage:cell.imageView.image];
        }
    }
    else if ([segue.identifier isEqualToString:@"showSlideShow"]) {
        if (self.imagesArray.count > 0) {
            SFRSlideShowViewController *photoViewer = segue.destinationViewController;
            [photoViewer setImagesArray:self.imagesArray];
        }
    }
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SFRPhotoSetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SFRPhotoSetCollectionViewCell" forIndexPath:indexPath];
    
    NSDictionary *photoDict = [self.imagesArray objectAtIndex:indexPath.row];
    
    if (photoDict[kUrlKey]) {
        NSString *urlString = photoDict[kUrlKey];
        NSURL *url = [NSURL URLWithString:urlString];
        [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        SFRAlbumHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SFRAlbumHeaderCollectionReusableView" forIndexPath:indexPath];
        [headerView setDelegate:self];
        
        if (self.albumDictionary[kTitleKey][kContentKey]) {
            NSString *title = self.albumDictionary[kTitleKey][kContentKey];
            [headerView.albumTitleLabel setText:title];
        }
        self.albumTitleLabel = headerView.albumTitleLabel;
        
        if ([self.photosCollectionView numberOfItemsInSection:0] > 0) {
            [headerView.slideShowButton setEnabled:YES];
        }
        else {
            [headerView.slideShowButton setEnabled:NO];
        }
        self.headerButton = headerView.slideShowButton;
        
        reusableview = headerView;
    }

    return reusableview;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showPhoto" sender:self];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canFocusItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    [self applyFocusWithContext:context];
}

- (nullable NSIndexPath *)indexPathForPreferredFocusedViewInCollectionView:(UICollectionView *)collectionView {
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

#pragma mark - SFRAlbumHeaderDelegate methods

- (void)startSlideShow {
    [self performSegueWithIdentifier:@"showSlideShow" sender:self];
}

@end
