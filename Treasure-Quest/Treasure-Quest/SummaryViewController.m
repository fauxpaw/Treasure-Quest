//
//  SummaryViewController.m
//  Treasure-Quest
//
//  Created by Rick  on 8/4/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import "SummaryViewController.h"
#import "FoursquareAPI.h"
#import "WaitPageViewController.h"
#import "Route.h"
#import "Objective.h"
@import Parse;
#import "Objective.h"

@interface SummaryViewController ()

@property (strong, nonatomic) NSMutableArray *searchResults;
@property (weak, nonatomic) IBOutlet UILabel *questNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPlayersLabel;
@property (weak, nonatomic) IBOutlet UILabel *objectivesLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
- (IBAction)createButtonSelected:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *createButtonSelected;

@end

@implementation SummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    self.createButtonSelected.alpha = 0;
    [UIView animateWithDuration:2.5 delay:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.createButtonSelected.alpha = 1.0;
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *token = @"IPVFQK21YIYRBOAM3JHLKAQXDU2LSDVAUFBLZ1ILNINHBMZY";
    
    self.finalLat = [NSString stringWithFormat:@"%f", self.finalCoordinate.latitude];
    self.finalLong = [NSString stringWithFormat:@"%f", self.finalCoordinate.longitude];
    NSLog(@"Lat: %@, long: %@", self.finalLat, self.finalLong);
    
    
    if (token)
    {
        [FoursquareAPI getFoursquareData:@"query" finalLat:self.finalLat finalLong:self.finalLong radius:[self.maxDistance stringValue] completionHandler:^(NSArray *results, NSError *error) {
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            }
            
            self.searchResults = [[NSMutableArray alloc] initWithArray:results];
            
            self.creatorObjectives = [[NSMutableArray alloc]init];
            
            if ((int)self.searchResults.count > self.objectives.intValue) {
                while ((int)self.creatorObjectives.count < (self.objectives.intValue -1)) {
                    int index = arc4random_uniform((int)self.searchResults.count);
                    if (![self.creatorObjectives containsObject:[self.searchResults objectAtIndex:index]]) {
                        [self.creatorObjectives addObject:[self.searchResults objectAtIndex:index]];
                    }
                }
                self.createButtonSelected.hidden = NO;
            } else {
                [self alert:@"Too many objectives" message:@"There weren't enough objective in your area.  (30 objectives max and may need to increase your range)"];
                self.createButtonSelected.hidden = YES;
            }
            
            Objective *finalObjective = [[Objective alloc]init];
            finalObjective.name = @"The Final Destination!";
            finalObjective.category = @"Final Destination!";
            finalObjective.latitude = self.finalCoordinate.latitude;
            finalObjective.longitude = self.finalCoordinate.longitude;
            
            [self.creatorObjectives addObject:finalObjective];            
        }];
    }
}

- (void)setupView {
    self.questNameLabel.text = self.questName;
    self.numberOfPlayersLabel.text = [NSString stringWithFormat:@"Players: %@", self.players];
    self.objectivesLabel.text = [NSString stringWithFormat:@"Total Objectives: %@", self.objectives];
    self.descriptionLabel.text = self.gameDescription;
}


- (IBAction)createButtonSelected:(UIButton *)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.color = [UIColor darkGrayColor];
    [self.view addSubview:spinner];
    spinner.center = CGPointMake(self.view.center.x, self.view.center.y);
    spinner.tag = 12;
    [spinner startAnimating];
    
    Quest *quest = [Quest objectWithClassName:@"Quest"];
    quest[@"name"] = self.questName;
    quest[@"info"] = self.gameDescription;
    quest[@"maxplayers"] = self.players;
    NSMutableArray *currentPlayers = [[NSMutableArray alloc]init];
    [currentPlayers addObject:[PFUser currentUser].objectId];
    
    quest[@"players"] = currentPlayers;
    int count = self.objectives.intValue;
    
    NSMutableArray *objectives = [[NSMutableArray alloc]init];
    objectives = [Objective verifyDistanceRange:self.creatorObjectives players:self.players.intValue];
    quest[@"objectives"] = objectives;
    
    NSMutableArray *zeroArray = [[NSMutableArray alloc]init];
    for (int index = 0 ; index < count ; index ++){
        [zeroArray addObject:@NO];
    }
    NSMutableArray *objectivesCompleted = [[NSMutableArray alloc]init];
    [objectivesCompleted addObject:zeroArray];
     quest[@"objectivesCompleted"] = objectivesCompleted;
    NSMutableArray *objectivesMessaged = [[NSMutableArray alloc]init];
    [objectivesMessaged addObject:zeroArray];
     quest[@"objectivesMessaged"] = objectivesMessaged;

    
    [quest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            [[PFUser currentUser]setObject:quest.objectId forKey:@"currentQuestId"];
            [[PFUser currentUser] saveInBackground];
            
            WaitPageViewController *viewController = [[UIStoryboard storyboardWithName:@"Waiting" bundle:nil] instantiateViewControllerWithIdentifier:@"waitingStoryboard"];

            NSLog(@"Saved successfully");
            viewController.questName = self.questName;
            viewController.gameCode = quest.objectId;

            [[self.view viewWithTag:12] stopAnimating];
            
            [self.navigationController pushViewController:viewController animated:YES];
//            NSLog(@"Current user: %@, created questid: %@", [PFUser currentUser].username, quest.objectId);

            
        } else {
            [[self.view viewWithTag:12] stopAnimating];
            [self alert:@"Error Saving" message:@"Quest unable to save, please try again."];

            NSLog(@"ERROR: %@:", error);
        }
    }];
}

- (void)alert:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
