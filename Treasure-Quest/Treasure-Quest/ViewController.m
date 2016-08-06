//
//  ViewController.m
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/4/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import "ViewController.h"
#import "SetupViewController.h"
#import "PlayfieldViewController.h"
#import <Parse/Parse.h>
@import ParseUI;


@interface ViewController ()<MKMapViewDelegate, MKAnnotation, CLLocationManagerDelegate, LocationManagerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //Test record creation on server
    
//    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
//    testObject[@"dog"] = @"nova";
//    
//    [testObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        
//        if (!error) {
//            [NSOperationQueue mainQueue]addOperationWithBlock:^{
//                //            NSLog(@"Success!");
//
//            }
//
//        } else {
//            NSLog(@"ERROR: %@", error.localizedDescription);
//        }
//        
//        
//    }];
    
    [self login];
}

+(ViewController *)sharedController
{
    static ViewController *sharedController = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedController = [[ViewController alloc]init];
    });
    
    return sharedController;
}

-(instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 20;
    }
    [_locationManager requestAlwaysAuthorization];
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [self.delegate locationControllerDidUpdateLocation:locations.lastObject];
    [self setLocation:locations.lastObject];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    
    notification.alertTitle = @"You have reached the questination!";
    notification.alertBody = @"Are you ready to continue?";
    
    [[UIApplication sharedApplication]presentLocalNotificationNow:notification];
}

#pragma mark - Login

-(void)login {
    
    if (![PFUser currentUser]) {
        
        PFLogInViewController *loginVC = [[PFLogInViewController alloc]init];
        loginVC.view.backgroundColor = [UIColor darkGrayColor];
        loginVC.delegate = self;
        loginVC.signUpController.delegate = self;
        UILabel *logoLabel = [[UILabel alloc]init];
        logoLabel.text = @"Treasure Quest";
        logoLabel.textColor = [UIColor whiteColor];
        [logoLabel setFont:[UIFont boldSystemFontOfSize:36]];
        loginVC.logInView.logo = logoLabel;
        
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        [self setup];
    }
    
}

-(void)setup {
    
    UIBarButtonItem *signOutButton = [[UIBarButtonItem alloc]initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(signOut)];
    self.navigationItem.leftBarButtonItem = signOutButton;
    
}

-(void)signOut {
    [PFUser logOut];
    [self login];
}

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self setup];
}
-(void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self setup];
}



@end
