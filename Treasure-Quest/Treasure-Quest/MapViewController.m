//
//  MapViewController.m
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/5/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import "MapViewController.h"
@import MapKit;
#import "LocationController.h"
#import "Quest.h"
#import "Objective.h"
#import "ProgressListViewController.h"
#import "TabBarViewController.h"
#import <AudioToolbox/AudioServices.h>

@interface MapViewController () <MKMapViewDelegate, LocationControllerDelegate>
- (IBAction)completeButtonSelected:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property float angleToNextObjective;
@property (strong, nonatomic) MKPinAnnotationView *userPin;
@property (nonatomic) BOOL completed;

@end

@implementation MapViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    [self.mapView.layer setCornerRadius:20.0];
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setDelegate:self];
    [self.mapView setZoomEnabled:NO];
    [self.mapView setScrollEnabled:NO];
    [self.mapView setRotateEnabled:NO];
    [self.mapView setShowsBuildings:YES];
    [self.mapView setPitchEnabled:YES];
    [self.mapView setShowsPointsOfInterest:YES];
    self.completed = NO;
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"XYZ" style:UIBarButtonSystemItemStop target:self action:@selector(completeButtonSelected:)];

    self.navigationItem.rightBarButtonItem = anotherButton;
    ((TabBarViewController *)self.parentViewController).navigationItem.rightBarButtonItem = anotherButton;
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [[LocationController sharedController]setDelegate:self];
    [[[LocationController sharedController]locationManager]startUpdatingLocation];
    [[[LocationController sharedController] locationManager]startUpdatingHeading];
    [self setupObjectiveAnnotations];
    [self setUpRegion:((TabBarViewController *)self.parentViewController).currentObjective];
    self.mapView.camera.altitude = 250;
    
}

-(void)setupObjectiveAnnotations {
    
    NSUInteger index = 0;

    NSNumber *playerNumber = [NSNumber numberWithInt:(int)([((TabBarViewController *)self.parentViewController).currentQuest.players indexOfObject:[PFUser currentUser].objectId])];
    
    NSArray *objectives = [[NSArray alloc]init];
    objectives = [((TabBarViewController *)self.parentViewController).currentQuest.objectives objectAtIndex:playerNumber.intValue];
    
    Objective *current = [[Objective alloc]init];
    current = objectives[index];

    while (current.completed == YES && index < objectives.count) {
        NSLog(@"completed: %@", current.name);
        index++;

        if(index == objectives.count){
            NSLog(@"end of array reached");
            return;
        }

        CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(current.latitude, current.longitude);
        MKPointAnnotation *newPoint = [[MKPointAnnotation alloc]init];
        newPoint.coordinate = loc;
        newPoint.title = current.name;
        [self.mapView addAnnotation:newPoint];

        current = objectives[index];

    }

    ((TabBarViewController *)self.parentViewController).currentObjective = current;
}



-(void)locationControllerDidUpdateLocation:(CLLocation *)location{

    [self.mapView setVisibleMapRect:MKMapRectMake(0, 0, 25, 25) animated:YES];

    [self.mapView setCenterCoordinate:location.coordinate animated:YES];
    self.mapView.camera.heading = self.currentHeading;
    self.mapView.camera.pitch = 60;
    self.mapView.camera.altitude = 250;
//    NSLog(@"you done moved");
//    self.mapView.camera.centerCoordinate = location.coordinate;
    CLLocation *locationPointer = [[CLLocation alloc]initWithLatitude:((TabBarViewController *)self.parentViewController).currentObjective.latitude longitude:((TabBarViewController *)self.parentViewController).currentObjective.longitude];
    [self calculateAngleToNewObjective:location objectiveLocation:locationPointer];
    self.currentUserLocation = location;
    [self calculateAngleToNewObjective:self.currentUserLocation objectiveLocation:locationPointer];
    [self changeUserAnnotationColor:self.userPin];
    [self distanceToObjective];

}

-(void)locationControllerDidUpdateHeading:(CLHeading *)heading {

    self.mapView.camera.heading = heading.trueHeading;
    self.mapView.camera.pitch = 60;
    self.mapView.camera.altitude = 250;

    CLLocation *locationPointer = [[CLLocation alloc]initWithLatitude:((TabBarViewController *)self.parentViewController).currentObjective.latitude longitude:((TabBarViewController *)self.parentViewController).currentObjective.longitude];

    self.currentHeading = heading.trueHeading;
    [self calculateAngleToNewObjective:self.currentUserLocation objectiveLocation:locationPointer];

//   NSLog(@"User Heading: %f   Angle to next: %f", self.currentHeading, self.angleToNextObjective);
    [self changeUserAnnotationColor:self.userPin];
    [self distanceToObjective];

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

//    annotationView.canShowCallout = YES;
    
    
    return annotationView;
}

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

- (float)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}

-(void) calculateAngleToNewObjective:(CLLocation *)userLocation objectiveLocation: (CLLocation *)objectiveLocation {

    float userLatRadians = degreesToRadians(userLocation.coordinate.latitude);
    float userLongRadians = degreesToRadians(userLocation.coordinate.longitude);
    
    float objectiveLatRadians = degreesToRadians(objectiveLocation.coordinate.latitude);
    float objectiveLongRadians = degreesToRadians(objectiveLocation.coordinate.longitude);

    float deltaLong = objectiveLongRadians - userLongRadians;
    float y = sin(deltaLong) * cos(objectiveLatRadians);
    float x = cos(userLatRadians) * sin(objectiveLatRadians) - sin(userLatRadians) * cos(objectiveLatRadians) * cos(deltaLong);
    float bearingInRadians = atan2f(y, x);
    self.angleToNextObjective = fmod(((bearingInRadians * 180 / M_PI) + 360), 360);
}

-(MKPinAnnotationView*)changeUserAnnotationColor: (MKPinAnnotationView *)userPin {
    //TODO: adjust opacity based on accuracy percentage

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

-(void)completeCurrentObjective {
 
    NSUInteger index = 0;
    ((TabBarViewController *)self.parentViewController).currentObjective.completed = YES;
//    Quest *quest = ((TabBarViewController *)self.parentViewController).currentQuest;
    
    [((TabBarViewController *)self.parentViewController).currentQuest fetch];

    NSNumber *playerNumber = [NSNumber numberWithInt:(int)([((TabBarViewController *)self.parentViewController).currentQuest.players indexOfObject:[PFUser currentUser].objectId])];

    NSArray *objectives = [[NSArray alloc]init];
    objectives = [((TabBarViewController *)self.parentViewController).currentQuest.objectives objectAtIndex:playerNumber.intValue];
    
    NSMutableArray *objectivesCompleted = [[NSMutableArray alloc]init];
    objectivesCompleted = [((TabBarViewController *)self.parentViewController).currentQuest.objectivesCompleted objectAtIndex:playerNumber.intValue];
    
    NSMutableArray *objectivesMessaged = [[NSMutableArray alloc]init];
    objectivesMessaged = [((TabBarViewController *)self.parentViewController).currentQuest.objectivesMessaged objectAtIndex:playerNumber.intValue];


    while (index < objectives.count) {
//        Objective *objective = [objectives objectAtIndex: index];
        Boolean test = [[objectivesCompleted objectAtIndex:index] boolValue];
        if (![[objectivesCompleted objectAtIndex:index] boolValue] ){
            break;
        }
        else {
           index++;
        }
        
    }

    if (index == objectives.count){
        NSLog(@"end of the line");
        if(((TabBarViewController *)self.parentViewController).currentObjective.messageSent == NO ) {
            [self WinnerFound];
            ((TabBarViewController *)self.parentViewController).currentObjective.messageSent = YES;
            
        }
        
        return;
    }

    ((TabBarViewController *)self.parentViewController).currentObjective = objectives[index];

    //    NSLog(@"Objective complete! Next objective is objective %@", self.tabbar.currentObjective.name);
    
    [self setupObjectiveAnnotations];
    [self setUpRegion:((TabBarViewController *)self.parentViewController).currentObjective];
    
    // Let's only send this message once per objective.
    if(((TabBarViewController *)self.parentViewController).currentObjective.messageSent == NO ) {
        NSString *message = [NSString stringWithFormat:@"%@ has reached goal #%i!!", [PFUser currentUser].username, (int)index + 1 ];
        [self questPushNotification:message];
        ((TabBarViewController *)self.parentViewController).currentObjective.messageSent = YES;
        
    }
    NSLog(@"saving Objective: %@", ((TabBarViewController *)self.parentViewController).currentObjective.objectId);
        [((TabBarViewController *)self.parentViewController).currentObjective save];
    
    
    
    // Let's save it in the new way
    [objectivesCompleted replaceObjectAtIndex:index withObject:@YES];
    [((TabBarViewController *)self.parentViewController).currentQuest.objectivesCompleted replaceObjectAtIndex:playerNumber.intValue withObject:objectivesCompleted];
    
    NSLog(@"completedArray: %@", [((TabBarViewController *)self.parentViewController).currentQuest.objectivesCompleted objectAtIndex:playerNumber.intValue]);
    NSLog(@"Full Array: %@", ((TabBarViewController *)self.parentViewController).currentQuest.objectivesCompleted);

    [((TabBarViewController *)self.parentViewController).currentQuest save];
    
    PFObject *updateQuest = [PFObject objectWithoutDataWithClassName:@"Quest" objectId:[[PFUser currentUser] objectForKey:@"currentQuestId"]];
    
    NSMutableArray *allObjectivesCompleted = [[NSMutableArray alloc]init];
    allObjectivesCompleted = ((TabBarViewController *)self.parentViewController).currentQuest.objectivesCompleted;
    
    
    updateQuest[@"objectivesCompleted"] = allObjectivesCompleted;
   
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        
        [updateQuest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(!error) {
                NSLog(@"Saved successfully @ Objective Completed");
            } else {
                NSLog(@"%@", error);
            }
        }];
    }];

    
    [(ProgressListViewController *)((TabBarViewController *)self.parentViewController).viewControllers.firstObject reloadCurrentObjectives];
}

-(void) setUpRegion: (Objective *)objective {
    
    CLLocationManager *manager = [[LocationController sharedController]locationManager];
    
//    for (CLRegion *monitored in [manager monitoredRegions]) {
//        [manager stopMonitoringForRegion:monitored];
//    }
    
    objective.range = @35;
    NSLog(@"Dis mah range bruh: %@", objective.range);

    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(objective.latitude, objective.longitude);

    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        CLCircularRegion *eventRegion = [[CLCircularRegion alloc]initWithCenter: coord radius:objective.range.floatValue identifier:objective.name];
        [[[LocationController sharedController]locationManager]startMonitoringForRegion:eventRegion];

        MKCircle *circle = [MKCircle circleWithCenterCoordinate:coord radius:objective.range.floatValue];

        [self.mapView addOverlay:circle];
    }

}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{

    MKCircleRenderer *circleRender = [[MKCircleRenderer alloc]initWithOverlay:overlay];
    circleRender.strokeColor = [UIColor blueColor];
    circleRender.lineWidth = 1;
    circleRender.fillColor = [UIColor redColor];
    circleRender.alpha = 0.25;

    return circleRender;

}

- (IBAction)completeButtonSelected:(UIButton *)sender {

    [self completeCurrentObjective];

}

- (void)questPushNotification: (NSString *)message  {

    [PFCloud callFunctionInBackground:@"iosPushToChannel"
                       withParameters:@{@"text":message,
                                        @"channel": [[PFUser currentUser] objectForKey:@"currentQuestId"]}
                                block:^(NSString *response, NSError *error) {
                                    if (!error) {
                                        NSLog(@"%@",response );
                                    }
                                }];
}

-(void)userDidEnterObjectiveRegion:(CLRegion *)region{
    
    NSLog(@"User entered region from mapviewcontroller");
    
    MKPointAnnotation *completedAnno = [[MKPointAnnotation alloc]init];
    [completedAnno setCoordinate:CLLocationCoordinate2DMake(((TabBarViewController *)self.parentViewController).currentObjective.latitude, ((TabBarViewController *)self.parentViewController).currentObjective.longitude)];
    
    MKAnnotationView *completedView = [[MKAnnotationView alloc]initWithAnnotation:completedAnno reuseIdentifier:@"completed"];
    completedView.canShowCallout = YES;
    
    
    UIButton *calloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    UITapGestureRecognizer *calloutTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(completeCurrentObjective)];
    completedView.leftCalloutAccessoryView = calloutButton;
    [completedView addGestureRecognizer:calloutTap];
    
    [self.mapView addAnnotation:completedAnno];
    [self completeCurrentObjective];
    
}

-(void)distanceToObjective{
    
    CLLocation *objectiveLocation = [[CLLocation alloc]initWithLatitude:((TabBarViewController *)self.parentViewController).currentObjective.latitude longitude:((TabBarViewController *)self.parentViewController).currentObjective.longitude];
    
    if ([self.currentUserLocation distanceFromLocation:objectiveLocation] <= 35) {
        
        NSLog(@"User entered region from mapviewcontroller");
        
        MKPointAnnotation *completedAnno = [[MKPointAnnotation alloc]init];
        [completedAnno setCoordinate:CLLocationCoordinate2DMake(((TabBarViewController *)self.parentViewController).currentObjective.latitude, ((TabBarViewController *)self.parentViewController).currentObjective.longitude)];
        
        MKAnnotationView *completedView = [[MKAnnotationView alloc]initWithAnnotation:completedAnno reuseIdentifier:@"completed"];
        completedView.canShowCallout = YES;
        
        
        UIButton *calloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        UITapGestureRecognizer *calloutTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(completeCurrentObjective)];
        completedView.leftCalloutAccessoryView = calloutButton;
        [completedView addGestureRecognizer:calloutTap];
        
        [self.mapView addAnnotation:completedAnno];
        [self completeCurrentObjective];
        
    
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Congratulations!"
                                                                                 message:@"You found the current objective!"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:actionOk];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
};

-(void)WinnerFound{
    if (!self.completed) {
        
        NSString *message = [NSString stringWithFormat:@"%@ has completed the quest!", [PFUser currentUser].username];
        [self questPushNotification:message];
        self.completed = YES;
        
    }

}

@end
