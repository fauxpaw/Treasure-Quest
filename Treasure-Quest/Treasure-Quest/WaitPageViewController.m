//
//  WaitPageViewController.m
//  Treasure-Quest
//
//  Created by Rick  on 8/5/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import "WaitPageViewController.h"

@interface WaitPageViewController ()
@property (weak, nonatomic) IBOutlet UILabel *questNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *gameDescriptionLabel;


@end

@implementation WaitPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)setupViewController {
    self.questNameLabel.text = @"Quest Name Variable Here";
    self.gameCodeLabel.text = @"game Code var";
    self.gameDescriptionLabel.text = @"description here";
    
}

@end
