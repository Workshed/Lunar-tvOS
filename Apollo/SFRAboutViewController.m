//
//  SFRAboutViewController.m
//  Apollo
//
//  Created by Daniel Leivers on 16/10/2015.
//  Copyright © 2015 Daniel Leivers. All rights reserved.
//

#import "SFRAboutViewController.h"
#import "UIImageView+Blur.h"
#import "NSString+File.h"

@interface SFRAboutViewController ()

@property (weak, nonatomic) IBOutlet UITextView *aboutText;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blurredBackgroundImageView;

@end

@implementation SFRAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadText];
    [self setupBackground];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupBackground {
    [self.blurredBackgroundImageView setImage:self.backgroundImageView.image];
    [self.blurredBackgroundImageView blurImageWithAlpha:0.6];
}

- (void)loadText {
    NSMutableAttributedString *aboutTitleTextString = [[NSMutableAttributedString alloc] initWithString:@"Project Apollo\n\n" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:36.0], NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    NSString *fileString = [NSString stringWithContentsOfTextFile:@"About"];
    NSMutableAttributedString *aboutTextString = [[NSMutableAttributedString alloc] initWithString:fileString attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:32.0], NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    NSString *timelineFileString = [NSString stringWithContentsOfTextFile:@"Timeline"];
    NSMutableAttributedString *timelineTextString = [[NSMutableAttributedString alloc] initWithString:timelineFileString attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:24.0], NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [aboutTextString appendAttributedString:timelineTextString];
    [aboutTitleTextString appendAttributedString:aboutTextString];
    
    [self.aboutText setAttributedText:aboutTitleTextString];
}

@end
