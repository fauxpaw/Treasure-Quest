//
//  EnterCodeViewController.m
//  Treasure-Quest
//
//  Created by Rick  on 8/8/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import "EnterCodeViewController.h"
@import Parse;
#import "Quest.h"
#import "WaitPageViewController.h"

@interface EnterCodeViewController () <UITextFieldDelegate>

- (IBAction)joinButtonSelected:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

@end

@implementation EnterCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.codeTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alert:(NSString *)title message:(NSString *)message {
    [[self.view viewWithTag:12] stopAnimating];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:actionOk];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)parseQuery {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.color = [UIColor darkGrayColor];
    [self.view addSubview:spinner];
    spinner.center = CGPointMake(self.view.center.x, self.view.center.y);
    spinner.tag = 12;
    [spinner startAnimating];
    PFQuery *query= [PFQuery queryWithClassName:@"Quest"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                for (Quest *quest in objects) {
                    
                    if ([quest.objectId isEqualToString:self.codeTextField.text]) {
                        self.questName = quest.name;
                        self.players = quest.players;
                        self.objectivesCompleted = quest.objectivesCompleted;
                        self.objectivesMessaged = quest.objectivesMessaged;
                        
                        if (![self.players containsObject:[PFUser currentUser].objectId]) {
                            if (self.players.count < quest.maxplayers.intValue) {
                                [self.players addObject:[PFUser currentUser].objectId];
                                
                                NSUInteger count = [[quest.objectives objectAtIndex:0] count];
                                NSMutableArray *zeroArray = [[NSMutableArray alloc]init];
                                for (int index ; index < count ; index ++){
                                    [zeroArray addObject:@NO];
                                }
                                
                                [self.objectivesCompleted addObject:zeroArray ];
                                [self.objectivesMessaged addObject:zeroArray];
                            } else {
                                [self alert:@"Game is Full" message:@"The game you are trying to join is full, please create a new one."];
                                return;
                            }
                        }
                        
                        PFObject *updateQuest = [PFObject objectWithoutDataWithClassName:@"Quest" objectId:quest.objectId];
                        updateQuest[@"players"] = self.players;
                        [[PFUser currentUser]setObject:quest.objectId forKey:@"currentQuestId"];
                        [[PFUser currentUser] saveInBackground];


                        [[NSOperationQueue mainQueue]addOperationWithBlock:^{

                        [updateQuest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                if(!error) {
                                    WaitPageViewController *viewController = [[UIStoryboard storyboardWithName:@"Waiting" bundle:nil] instantiateViewControllerWithIdentifier:@"waitingStoryboard"];
                                    NSLog(@"Saved successfully");
                                    [spinner stopAnimating];
                                    viewController.gameCode = self.codeTextField.text;
                                    viewController.questName = self.questName;
                                    
                                    [self.navigationController pushViewController:viewController animated:YES];
                                    return;
                                }
                            }];
                        }];
                    }
                }
            }];
        } else {
            [self alert:@"Invalid Code" message:@"Please retry your code or create a new quest."];
        }
    }];
    [spinner stopAnimating];
}

- (IBAction)joinButtonSelected:(UIButton *)sender {
    [self parseQuery];
    
}

#pragma Mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
