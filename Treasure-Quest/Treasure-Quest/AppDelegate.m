//
//  AppDelegate.m
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/4/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "EnterCodeViewController.h"
#import "Quest.h"
#import "WaitPageViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration>  _Nonnull configuration) {
        
        configuration.applicationId = @"tresQ";
        configuration.clientKey = @"bestGroup";
        configuration.server = @"https://treasure-quest-server.herokuapp.com/parse";
        
    }]];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
//    [self registerForNotification];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation setDeviceTokenFromData:deviceToken];
    installation.channels = @[ @"global" ];
    [installation saveInBackground];
//    NSLog(@"Shit is happening now");
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void) registerForNotification{
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    
    [[UIApplication sharedApplication]registerUserNotificationSettings:notificationSettings];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [PFPush handlePush:userInfo];
    NSLog(@"%@",userInfo);

    
}


//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
//    NSLog(@"URL scheme:%@", [url scheme]);
//    NSLog(@"URL query: %@", [url query]);
//    
//    return YES;
//}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
    NSLog(@"URL scheme:%@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    
    PFQuery *query= [PFQuery queryWithClassName:@"Quest"];
    [query whereKey:@"objectId" equalTo:[url query]];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                for (Quest *quest in objects) {
                    
                    if ([quest.objectId isEqualToString:[url query]]) {
                        NSString *questName = quest.name;
                        NSMutableArray *players = quest.players;
                        NSMutableArray *objectivesCompleted = quest.objectivesCompleted;
                        NSMutableArray *objectivesMessaged = quest.objectivesMessaged;

                        
                        //********** NEED TO ADD A CHECK TO MAKE SURE EXCESS USERS DON'T JOIN **********//
                        if (![players containsObject:[PFUser currentUser].objectId]) {
                            [players addObject:[PFUser currentUser].objectId];
                            
                            NSUInteger count = [[quest.objectives objectAtIndex:0] count];
                            NSMutableArray *zeroArray = [[NSMutableArray alloc]init];
                            for (int index ; index < count ; index ++){
                                [zeroArray addObject:@NO];
                            }
                            
                            [objectivesCompleted addObject:zeroArray ];
                            [objectivesMessaged addObject:zeroArray];
                        }
                        
                        PFObject *updateQuest = [PFObject objectWithoutDataWithClassName:@"Quest" objectId:quest.objectId];
                        updateQuest[@"players"] = players;
                        updateQuest[@"objectivesCompleted"] = objectivesCompleted;
                        updateQuest[@"objectivesMessaged"] = objectivesCompleted;

                        [[PFUser currentUser]setObject:quest.objectId forKey:@"currentQuestId"];
                        [[PFUser currentUser] saveInBackground ];
                        
                        
                        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                            
                            [updateQuest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                if(!error) {
                                    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
                                    WaitPageViewController *viewController = [[UIStoryboard storyboardWithName:@"Waiting" bundle:nil] instantiateViewControllerWithIdentifier:@"waitingStoryboard"];
                                    NSLog(@"Saved successfully");
                                    viewController.gameCode = [url query];
                                    viewController.questName = questName;
                                    
                                    [navigationController pushViewController:viewController animated:YES];
                                }
                            }];
                        }];
                    }
                }
            }];
        }
    }];
    return YES;
}
@end
