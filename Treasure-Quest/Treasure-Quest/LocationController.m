//
//  LocationController.m
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/5/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import "LocationController.h"
#import "MapViewController.h"
@import Parse;

@interface LocationController () <CLLocationManagerDelegate>

@end

@implementation LocationController

+(LocationController *)sharedController {
    
    static LocationController *sharedController = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[self alloc]init];
    });
    
    return sharedController;
}

-(instancetype)init {
    self = [super init];
    
    if (self) {
        
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 5;
        _locationManager.headingFilter = 3;
        
    }
    
    [_locationManager requestAlwaysAuthorization];
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    [self.delegate locationControllerDidUpdateLocation:locations.lastObject];
    [self setLocation:locations.lastObject];
    
    // write user location to server
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint * _Nullable geoPoint, NSError * _Nullable error) {
        [[PFUser currentUser] setObject:geoPoint forKey:@"userLocation"];
        [[PFUser currentUser] saveInBackground];
    }];
    

}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    [self.delegate locationControllerDidUpdateHeading:newHeading];
    
}



-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    [self.delegate userDidEnterObjectiveRegion:region];

    NSLog(@"User Did Enter Region from location manager");
    
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.alertTitle = @"You have entered a region";
    notification.alertBody = @"🐺 My emoji game is stronk";
    
    [[UIApplication sharedApplication]presentLocalNotificationNow:notification];
    
}

@end
