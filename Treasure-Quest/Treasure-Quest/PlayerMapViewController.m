//
//  MapViewController.m
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/5/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import "PlayerMapViewController.h"
@import MapKit;
#import "LocationController.h"
#import "Quest.h"
#import "Objective.h"
#import "ProgressListViewController.h"
#import "TabBarViewController.h"
#import <AudioToolbox/AudioServices.h>

@interface PlayerMapViewController () <MKMapViewDelegate, LocationControllerDelegate>
- (IBAction)completeButtonSelected:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property float angleToNextObjective;
@property (strong, nonatomic) MKPinAnnotationView *userPin;

@end

@implementation PlayerMapViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    //    NSLog(@"mapview view did load %@",((TabBarViewController *)self.parentViewController).currentQuest.name);
    //    NSLog(@"string value? %@",((TabBarViewController *)self.parentViewController).mystring);
    [self.mapView.layer setCornerRadius:20.0];
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setDelegate:self];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    [self.mapView setRotateEnabled:NO];
    [self.mapView setShowsBuildings:NO];
    [self.mapView setPitchEnabled:NO];
    [self.mapView setShowsPointsOfInterest:NO];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
    [self.mapView setMapType:MKMapTypeStandard];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [[LocationController sharedController]setDelegate:self];
    [[[LocationController sharedController]locationManager]startUpdatingLocation];
    [[[LocationController sharedController] locationManager]startUpdatingHeading];
    //    ProgressListViewController *progressListVC = (ProgressListViewController *)[self.tabBarController.viewControllers objectAtIndex:0];
    //    self.tabbar.currentQuest = progressListVC.currentQuest;
    [self setupPlayerAnnotations];
    
}

-(void)setupPlayerAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];

    
        for (NSString *user in ((TabBarViewController *)self.parentViewController).currentQuest.players) {
            
            PFQuery * query = [PFUser query];
            [query whereKey:@"objectId" equalTo:user];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                for (PFUser *user  in objects) {
                    NSLog(@"%@, %@", user.objectId, [PFUser currentUser].objectId);
                    if (![user.objectId isEqualToString: [PFUser currentUser].objectId]) {
                        
                        NSLog(@"Test: %@, Location: %@", user.username, [user objectForKey:@"userLocation"]);
                        PFGeoPoint *userLocation = [user objectForKey:@"userLocation"];
                        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(userLocation.latitude, userLocation.longitude);
                        MKPointAnnotation *newPoint = [[MKPointAnnotation alloc]init];
                        newPoint.coordinate = loc;
                        newPoint.title = user.username;
                        [self.mapView addAnnotation:newPoint];
                        [self.mapView selectAnnotation:newPoint animated:NO];
                    }

                }
                    [self.mapView showAnnotations:self.mapView.annotations animated:YES];

            }];
            
        
        }


}


-(void)locationControllerDidUpdateLocation:(CLLocation *)location{


    [self setupPlayerAnnotations];

}

-(void)locationControllerDidUpdateHeading:(CLHeading *)heading {



}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    if ([annotation isKindOfClass:[MKUserLocation class]]) {

        self.userPin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"userAnno"];
        self.userPin.pinTintColor = [UIColor purpleColor];

        return [self changeUserAnnotationColor:self.userPin];

    }

    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"annotationView"];

    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"annotationView"];
    }

    annotationView.canShowCallout = YES;
    UIButton *calloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.rightCalloutAccessoryView = calloutButton;
    return annotationView;
}


-(MKPinAnnotationView*)changeUserAnnotationColor: (MKPinAnnotationView *)userPin {
    //TODO: adjust opacity based on accuracy percentage
    //float difference = fabs(self.currentHeading - self.angleToNextObjective);

    if (self.currentHeading <= self.angleToNextObjective + 10 && self.currentHeading >= self.angleToNextObjective - 10) {

        self.userPin.pinTintColor = [UIColor greenColor];
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        return userPin;

    }

        else if(self.currentHeading <= self.angleToNextObjective + 50 && self.currentHeading >= self.angleToNextObjective - 50) {
            self.userPin.pinTintColor = [UIColor yellowColor];
            return userPin;
    
        }

    else {

        self.userPin.pinTintColor = [UIColor redColor];
        return userPin;
    }

}




@end
