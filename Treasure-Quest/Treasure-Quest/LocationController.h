//
//  LocationController.h
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/5/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@protocol LocationControllerDelegate <NSObject>

-(void)locationControllerDidUpdateLocation:(CLLocation *)location;
-(void)locationControllerDidUpdateHeading:(CLHeading *)heading;
-(void)userDidEnterObjectiveRegion:(CLRegion *)region;
-(void)monitoringDidFail:(CLRegion *)region;

@end

@interface LocationController : NSObject

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;
@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) CLLocation *pinLocation;
+(LocationController *)sharedController;



@end
