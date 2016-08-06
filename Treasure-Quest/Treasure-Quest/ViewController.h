//
//  ViewController.h
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/4/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
@import UIKit;
@import CoreLocation;

@protocol LocationManagerDelegate <NSObject>

-(void)locationControllerDidUpdateLocation:(CLLocation *)location;

@end

@interface ViewController : UIViewController

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@property (weak, nonatomic) id delegate;

+(ViewController *)sharedController;


@end

