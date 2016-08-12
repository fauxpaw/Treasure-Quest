//
//  Objective.h
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/5/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Parse;
@import MapKit;

@interface Objective : PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSNumber *range;
@property Boolean completed;
@property Boolean messageSent;
//@property CLLocation *location;
@property double latitude;
@property double longitude;

+(instancetype)initWith: (NSString *)name imageURL:(NSString *)imageURL info:(NSString *)info category: (NSString *)category range: (NSNumber *)range latitude:(double)lat longitude:(double)lon;

+ (double)totalDistanceCrowFlies:(NSMutableArray *)objectives;
+ (NSMutableArray *)randomizeObjectives:(NSMutableArray *)originalRoute;
+ (NSMutableArray *)verifyDistanceRange:(NSMutableArray *)originalObjectives players:(int)players;

@end
