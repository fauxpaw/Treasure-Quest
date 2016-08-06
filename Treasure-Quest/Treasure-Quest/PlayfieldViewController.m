//
//  PlayfieldViewController.m
//  Treasure-Quest
//
//  Created by Rick  on 8/4/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import "PlayfieldViewController.h"
#import "ViewController.h"

@import Parse;
@import ParseUI;

@interface PlayfieldViewController () <MKMapViewDelegate, MKAnnotation, LocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation PlayfieldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mapView.layer setCornerRadius:20.0];
    [self.mapView setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupFinalDestination
{
    PFQuery *query = [PFQuery queryWithClassName:@"FinalDestination"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error)
        {
            [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                for (id object in objects)
                {
                    PFGeoPoint *finalDesintation = object[@"location"];
                    MKPointAnnotation *newPoint = [[MKPointAnnotation alloc]init];
                    
                    CLLocationCoordinate2D newCoordinate = CLLocationCoordinate2DMake(finalDesintation.latitude, finalDesintation.longitude);
                    [[[ViewController sharedController]locationManager]startMonitoringVisits];
                    
                    newPoint.coordinate = newCoordinate;
                    newPoint.title = object[@"name"];
                    [self.mapView addAnnotation:newPoint];
                }
            }];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[ViewController sharedController]setDelegate:self];
    [[[ViewController sharedController]locationManager]startUpdatingLocation];
}

-(void)locationControllerDidUpdateLocation:(CLLocation *)location
{
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, 500.0, 500.0) animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(nonnull id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"annotationView"];
    
    if (!annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"annotationView"];
    }
    
    annotationView.canShowCallout = YES;
    
    return annotationView;
}


@end
