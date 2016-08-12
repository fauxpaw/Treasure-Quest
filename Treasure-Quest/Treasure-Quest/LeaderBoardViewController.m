//
//  LeaderBoardViewController.m
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/5/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import "LeaderBoardViewController.h"
//#import <Parse/Parse.h>
#import "Quest.h"
#import "TabBarViewController.h"
#import "Objective.h"

@import Parse;


@interface LeaderBoardViewController () 
@property (strong, nonatomic) IBOutlet UIView *pushTestButton;
@property (weak, nonatomic) IBOutlet UIButton *textSendButton;
@property (strong, nonatomic) Quest *currentQuest;

@property (weak, nonatomic) IBOutlet UILabel *textfield;
@end




@implementation LeaderBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self drawLeaderBoard];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self drawLeaderBoard];
}

- (IBAction)sendTextButtonPressed:(id)sender {
    
}
-(void)drawLeaderBoard {
    NSMutableString *leaderBoardText = [[NSMutableString alloc]init];;
    
    PFQuery *query= [PFQuery queryWithClassName:@"Quest"];
    [query whereKey:@"objectId" equalTo:[[PFUser currentUser] objectForKey:@"currentQuestId"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        for (Quest *quest in objects)
        {
            for (int index = 0; index < quest.players.count; index++) {
                NSArray *allObjectivesCompleted = [[NSArray alloc] init];
                allObjectivesCompleted = quest.objectivesCompleted;
                
                NSArray *objectivesCompleted = [[NSArray alloc]init];
                objectivesCompleted = allObjectivesCompleted[index];
                
                int innerIndex = 0;
                while (innerIndex < objectivesCompleted.count ) {
                    //            Objective *objective = [[Objective alloc] init];
                    if (![[objectivesCompleted objectAtIndex:innerIndex] boolValue] ){
                        break;
                    } else {
                        innerIndex++;
                    }
                    
                }
                switch (index) {
                    case 0:
                        [leaderBoardText appendString:@"Blue Team"];
                        break;
                    case 1:
                        [leaderBoardText appendString:@"Red Team"];
                        break;
                    case 2:
                        [leaderBoardText appendString:@"Green Team"];
                        break;
                    case 3:
                        [leaderBoardText appendString:@"Orange Team"];
                        break;
                    case 4:
                        [leaderBoardText appendString:@"Purple Team"];
                        break;
                    case 5:
                        [leaderBoardText appendString:@"Black Team"];
                        break;
                    default:
                        break;
                }
                [leaderBoardText appendString:[NSString stringWithFormat:@": %d/%lu\n", innerIndex, (unsigned long)objectivesCompleted.count ]];
                //                NSLog(@"Player %@ completed: %d/%lu/n" );
                
            }
            NSLog(@"%@", leaderBoardText);
            self.textfield.text = leaderBoardText;
        }
        
    }];
    

}

- (IBAction)pushTestButtonPressed:(id)sender {
    NSLog(@"got it");
    
//    @"LuX5l9Yirp"
//    [[PFUser currentUser] fetch];
    
    NSString *message = [NSString stringWithFormat:@"%@ has joined the quest!", [PFUser currentUser].username];
    [PFCloud callFunctionInBackground:@"iosPushTest"
                       withParameters:@{@"text": message }
                                block:^(NSString *response, NSError *error) {
                                    if (!error) {
                                        // ratings is 4.5
                                        NSLog(@"%@",response );
                                    }
                                }];
    [PFCloud callFunctionInBackground:@"iosPushToChannel"
                       withParameters:@{@"text": @"TEST CHANNEL SEND",
                                        @"channel": [[PFUser currentUser] objectForKey:@"currentQuestId"]}
                                block:^(NSString *response, NSError *error) {
                                    if (!error) {
                                        // ratings is 4.5
                                        NSLog(@"%@",response );
                                    }
                                }];
}

- (void) setup {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    
    [currentInstallation addUniqueObject:[[PFUser currentUser] objectForKey:@"currentQuestId"] forKey:@"channels"];
    [currentInstallation saveInBackground];
    NSLog(@"%@",[PFInstallation currentInstallation].channels);
    
    
//    PFQuery *query= [PFQuery queryWithClassName:@"Quest"];
//    [query getObjectWithId:@"LuX5l9Yirp"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//    {
//        PFObject *obj = [objects firstObject];
//        NSLog(@"%@", obj);
//    }];

    
}


@end
