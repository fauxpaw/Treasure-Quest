//
//  ProgressListViewController.m
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/4/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import "ProgressListViewController.h"
#import "Quest.h"
#import "Player.h"
#import "Route.h"
#import "Objective.h"
@import Parse;
#import "MapViewController.h"
#import "TabBarViewController.h"
#import "JSONParser.h"

@interface ProgressListViewController () <UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (strong, nonatomic) Quest *currentQuest;

@end

@implementation ProgressListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self setup];
    
//    ((TabBarViewController *)self.parentViewController).currentQuest.name = @"new quest name";
//    NSLog(@"listview did load %@",((TabBarViewController *)self.parentViewController).currentQuest.name);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
}

-(void) setup {

   self.objectivesDisplayed = [[NSMutableArray alloc]init];
    self.objectivesCompleted = [[NSMutableArray alloc]init];

    
    PFQuery *query= [PFQuery queryWithClassName:@"Quest"];
    [query whereKey:@"objectId" equalTo:[[PFUser currentUser] objectForKey:@"currentQuestId"]];
//    [query includeKey:@"objectives"];
//    [query includeKey:@"objectivesCompleted"];
    
//    
//    PFQuery *testQuery = [PFQuery queryWithClassName:@"Quest"];
//    Quest *testObject = [testQuery getObjectWithId:[[PFUser currentUser] objectForKey:@"currentQuestId"]];
//    
    
    
    NSLog(@"current quest: %@", [[PFUser currentUser] objectForKey:@"currentQuestId"]);
    __weak typeof (self) weakSelf = self;

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                for (PFObject *pfquest in objects)
                {
                    
//                    NSLog(@"objectives: %@",[pfquest valueForKey:@"objectives"]);
//                    NSLog(@"objectivesCompleted: %@lu",[pfquest valueForKey:@"objectivesCompleted"]);
//                   [pfquest fetch];
                    Quest *myQuest = [[Quest alloc] init];
                    myQuest = (Quest*)pfquest;
//                 
//                    
//                    NSString *questName = myQuest.name;
//                    NSMutableArray *players = myQuest.players;
//                    NSMutableArray *objectivesCompleted = myQuest.objectivesCompleted;
//                    NSMutableArray *objectivesMessaged = myQuest.objectivesMessaged;
//                    
//                    NSLog(@"questname %@", myQuest.name);
//                    NSLog(@"objectives %lu", (unsigned long)objectivesCompleted.count);
//                    NSLog(@"objectives %lu", (unsigned long)objectivesMessaged.count);

//
                    NSNumber *playerNumber = [NSNumber numberWithInt:(int)([myQuest.players indexOfObject:[PFUser currentUser].objectId])];

//
                    PFQuery *query2 = [PFQuery queryWithClassName:@"Objective"];
                    
                   for (PFObject *pfobject in myQuest.objectives[playerNumber.intValue]){
                       [pfobject fetchIfNeeded];
                       Objective *objective = [[Objective alloc]init];
                       objective = (Objective*)pfobject;
                        NSLog(@"%@", objective.name);
                       [strongSelf.objectivesDisplayed addObject:objective];
                    }
                    [strongSelf.tableView reloadData];
                    
//                    for (PFObject *pfobject in myQuest.objectivesCompleted[playerNumber.intValue]){
//                        [pfobject fetchIfNeeded];
//                        Objective *objective = [[Objective alloc]init];
//                        objective = (Objective*)pfobject;
//                        NSLog(@"%@", objective.name);
//                        [strongSelf.objectivesCompleted addObject:objective];
//                    }
//                    [strongSelf.tableView reloadData];

                    strongSelf.objectivesCompleted = myQuest.objectivesCompleted[playerNumber.intValue];
                    strongSelf.objectivesMessaged = myQuest.objectivesMessaged[playerNumber.intValue];

                    ((TabBarViewController *)self.parentViewController).currentQuest = myQuest;
                    // I think this was our crash here - overwriting and array of arrays with an array...
//                    ((TabBarViewController *)self.parentViewController).currentQuest.objectives = strongSelf.objectivesDisplayed;
                    ((TabBarViewController *)self.parentViewController).currentObjective = strongSelf.objectivesDisplayed[0];
                    
                    
                    [self setupPushChannelForQuest];
                }
            }];
        } else {
            NSLog(@"ERROR: %@", error.localizedDescription);
        }
    }];
    
   
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    Objective *objective = [[Objective alloc] init];
    objective = self.objectivesDisplayed[indexPath.row];
    ;
//Boolean completed = ((TabBarViewController *)self.parentViewController).currentQuest.objectivesCompleted[indexPath.row];
//    [objective fetchIfNeeded];
//    NSLog(@"Objective name: %@", self.objectivesCompleted[indexPath.row]);
    
    if ( [self.objectivesCompleted[indexPath.row] boolValue]){
        cell.textLabel.text = [NSString stringWithFormat:@"✓ %@",objective.category];
    } else {
        cell.textLabel.text = objective.category;
    }
    
//      cell.textLabel.text = (self.objectivesCompleted[indexPath.row] == 1) ? [NSString stringWithFormat:@"✓ %@",objective.category] :objective.category ;
//    cell.textLabel.text = objective.name;
    return cell;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.objectivesDisplayed.count;
    
}

- (void) setupPushChannelForQuest {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    [currentInstallation addUniqueObject:[[PFUser currentUser] objectForKey:@"currentQuestId"] forKey:@"channels"];
    [currentInstallation saveInBackground];
    NSLog(@"Setting Up Channels: %@",[PFInstallation currentInstallation].channels);
    
}


@end
