//
//  Objective.h
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/5/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface Objective : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSNumber *range;
@property CLLocationCoordinate2D location;
@property Boolean completed;

+(instancetype)initWith: (NSString *)name imageURL:(NSString *)imageURL info:(NSString *)info category: (NSString *)category range: (NSNumber *)range location:(CLLocationCoordinate2D)location;
    

@end
