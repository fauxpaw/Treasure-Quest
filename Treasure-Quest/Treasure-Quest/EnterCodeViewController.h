//
//  EnterCodeViewController.h
//  Treasure-Quest
//
//  Created by Rick  on 8/8/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnterCodeViewController : UIViewController

@property(strong, nonatomic)NSString *questName;
@property(strong, nonatomic)NSMutableArray *players;
@property(strong, nonatomic)NSMutableArray *objectivesMessaged;
@property(strong, nonatomic)NSMutableArray *objectivesCompleted;


@end
