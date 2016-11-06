//
//  SFRAlbumListViewController.m
//  Apollo
//
//  Created by Daniel Leivers on 10/10/2015.
//  Copyright © 2015 Daniel Leivers. All rights reserved.
//

#import "SFRAlbumListViewController.h"
#import "FlickrKit.h"
#import "SFRPhotoSetCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "SFRAlbumViewController.h"
#import "SFRPhotoSetHeaderCollectionReusableView.h"
#import "SFRConstants.h"

#define COLLECTION_HEADER_HEIGHT 600
#define DEBUG_OUTPUT NO

@interface SFRAlbumListViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topCollectionViewConstraint;

@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (strong, nonatomic) NSArray *photoSetsJsonArray;

@end

@implementation SFRAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadAlbums];
}

- (void)loadAlbums {
    [self.collectionView setHidden:YES];
    
    [self.reloadButton setHidden:YES];
    [self.loadingIndicator setHidden:NO];
    [self.loadingIndicator startAnimating];
    [self.collectionView setUserInteractionEnabled:NO];
    FKFlickrPhotosetsGetList *photoSetList = [[FKFlickrPhotosetsGetList alloc] init];
    [photoSetList setUser_id:@"136485307@N06"];
    [photoSetList setPrimary_photo_extras:@"url_sq,url_t,url_s,url_m,url_o"];
    [[FlickrKit sharedFlickrKit] call:photoSetList maxCacheAge:FKDUMaxAgeOneDay completion:^(NSDictionary *response, NSError *error) {
        
        if (DEBUG_OUTPUT) {
            NSLog(@"Results %@", response);
        }
        
        [self.loadingIndicator setHidden:YES];
        [self.loadingIndicator stopAnimating];
        
        static NSString *kPhotoSets = @"photosets";
        static NSString *kPhotoSet = @"photoset";
        
        if (response[kPhotoSets][kPhotoSet] && [response[kPhotoSets][kPhotoSet] isKindOfClass:[NSArray class]]) {
            NSMutableArray *photosets = [NSMutableArray arrayWithArray:response[kPhotoSets][kPhotoSet]];
            if (photosets.count > 0) {
                NSDictionary *firstDict = [photosets firstObject];
                if ([firstDict[kTitleKey][kContentKey] isEqualToString:@"Announcements"]) {
                    [photosets removeObject:firstDict];
                }
                
                if (DEBUG_OUTPUT) {
                    // Count photos
                    for (NSDictionary *dict in photosets) {
                        NSLog(@"%@", dict[kTitleKey][kContentKey]);
                        NSLog(@"Number of photos: %@", dict[@"photos"]);
                    }
                }
            }
            self.photoSetsJsonArray = photosets;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.collectionView reloadData];
                [self animateCollectionView];
            }];
        }
        else {
            // Error - no internet or Flickr gallery gone...
            [self.reloadButton setHidden:NO];
        }
    }];
}

- (IBAction)reloadPressed:(id)sender {
    [self loadAlbums];
}

- (void)animateCollectionView {
    [self.topCollectionViewConstraint setConstant:self.view.bounds.size.height - COLLECTION_HEADER_HEIGHT];
    [self.view layoutIfNeeded];
    
    [self.collectionView setHidden:NO];
    [self.topCollectionViewConstraint setConstant:0];
    [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.collectionView setUserInteractionEnabled:YES];
        [self.collectionView setNeedsFocusUpdate];
    }];
}

- (void)applyFocusWithContext:(UICollectionViewFocusUpdateContext *)context andCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    
    static float scale = 1.3;
    
    SFRPhotoSetCollectionViewCell *cell = (SFRPhotoSetCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:context.nextFocusedIndexPath];
    [self.collectionView bringSubviewToFront:cell];
    [cell.titleLabel setClipsToBounds:YES];
    
    SFRPhotoSetCollectionViewCell *previousCell = nil;
    if (context.previouslyFocusedIndexPath) {
        previousCell = (SFRPhotoSetCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:context.previouslyFocusedIndexPath];
    }
    
    [coordinator addCoordinatedAnimations:^{
        NSTimeInterval duration = [UIView inheritedAnimationDuration];
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionOverrideInheritedDuration animations:^{
            cell.titleLabel.transform = CGAffineTransformScale(cell.titleLabel.transform, scale, scale);
        } completion:nil];
        
        if (previousCell) {
            [UIView animateWithDuration:duration delay:duration options:UIViewAnimationOptionOverrideInheritedDuration animations:^{
                
                previousCell.titleLabel.transform = CGAffineTransformScale(cell.titleLabel.transform, 1/ scale, 1 / scale);
            } completion:nil];
        }
    } completion:^{
        
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"showPhotoSet"]) {
        NSArray *selectedCells = [self.collectionView indexPathsForSelectedItems];
        if (selectedCells.count > 0) {
            NSIndexPath *selectedPath = [selectedCells firstObject];
            NSDictionary *selectedDictionary = [self.photoSetsJsonArray objectAtIndex:selectedPath.row];
            SFRAlbumViewController *albumViewController = segue.destinationViewController;
            [albumViewController setAlbumDictionary:selectedDictionary];
        }
    }
    
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoSetsJsonArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SFRPhotoSetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SFRPhotoSetCollectionViewCell" forIndexPath:indexPath];
    
    NSDictionary *photosetDict = [self.photoSetsJsonArray objectAtIndex:indexPath.row];
    if (photosetDict[kTitleKey][kContentKey]) {
        NSString *title = photosetDict[kTitleKey][kContentKey];
        [cell.titleLabel setText:title];
    }
    else {
        [cell.titleLabel setText:@""];
    }
    
    if (photosetDict[@"primary_photo_extras"][kUrlKey]) {
        NSString *urlString = photosetDict[@"primary_photo_extras"][kUrlKey];
        NSURL *url = [NSURL URLWithString:urlString];
        [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        SFRPhotoSetHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SFRPhotoSetHeaderCollectionReusableView" forIndexPath:indexPath];
        
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showPhotoSet" sender:self];    
}

- (BOOL)collectionView:(UICollectionView *)collectionView canFocusItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    [self applyFocusWithContext:context andCoordinator:coordinator];
}

@end
