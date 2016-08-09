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

@interface EnterCodeViewController ()
- (IBAction)joinButtonSelected:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

@end

@implementation EnterCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)parseQuery {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.color = [UIColor darkGrayColor];
    [self.view addSubview:spinner];
    spinner.center = CGPointMake(160, 250);
    spinner.tag = 12;
    [spinner startAnimating];
    PFQuery *query= [PFQuery queryWithClassName:@"Quest"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                for (Quest *quest in objects)
                {
                    if ([quest.objectId isEqualToString:self.codeTextField.text]) {
                        self.questName = quest.name;
                        self.players = quest.players;
                        
                         //********** NEED TO ADD A CHECK TO MAKE SURE EXCESS USERS DON'T JOIN **********//
                        if (![self.players containsObject:[PFUser currentUser].objectId]) {
                            [self.players addObject:[PFUser currentUser].objectId];
                        }
                        
                        PFObject *updateQuest = [PFObject objectWithoutDataWithClassName:@"Quest" objectId:quest.objectId];
                        updateQuest[@"players"] = self.players;
                        [updateQuest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if(!error) {
                                WaitPageViewController *viewController = [[UIStoryboard storyboardWithName:@"Waiting" bundle:nil] instantiateViewControllerWithIdentifier:@"waitingStoryboard"];
                                NSLog(@"Saved successfully");
                                viewController.questName = self.questName;
                                
                                [[self.view viewWithTag:12] stopAnimating];
                                [self.navigationController pushViewController:viewController animated:YES];
                                
                            }
                        }];

                        
                    } else {
                        [[self.view viewWithTag:12] stopAnimating];
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invalid Code"
                                                                                                 message:@"Please retry your code or create a new quest."
                                                                                          preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                        [alertController addAction:actionOk];
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                }
            }];
        }
    }];
    [[self.view viewWithTag:12] stopAnimating];

}

- (IBAction)joinButtonSelected:(UIButton *)sender {
    [self parseQuery];
    
}
@end