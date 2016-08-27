//
//  ProgressListViewController.h
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/4/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Quest.h"
#import "Objective.h"

@interface ProgressListViewController : UIViewController

@property (strong, nonatomic) Quest *currentQuest;
@property (strong, nonatomic) Objective *currentObjective;
@property (strong, nonatomic) NSMutableArray *objectivesDisplayed;
@property (strong, nonatomic) NSMutableArray *objectivesCompleted;
@property (strong, nonatomic) NSMutableArray *objectivesMessaged;

- (void) reloadCurrentObjectives;

@end
