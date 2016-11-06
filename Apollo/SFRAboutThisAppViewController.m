//
//  SFRAboutThisAppViewController.m
//  Apollo
//
//  Created by Daniel Leivers on 18/10/2015.
//  Copyright © 2015 Daniel Leivers. All rights reserved.
//

#import "SFRAboutThisAppViewController.h"
#import "UIImageView+Blur.h"

@interface SFRAboutThisAppViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
 
@end

@implementation SFRAboutThisAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupBackground];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Work around for iOS/tvOS bug: http://stackoverflow.com/questions/18696706/large-text-being-cut-off-in-uitextview-that-is-inside-uiscrollview
    self.textView.scrollEnabled = NO;
    self.textView.scrollEnabled = YES;
}

- (void)setupBackground {
    [self.backgroundImageView setImage:self.backgroundImageView.image];
    [self.backgroundImageView blurImageWithAlpha:0.6];
}

@end
