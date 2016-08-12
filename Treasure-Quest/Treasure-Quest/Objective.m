//
//  Objective.m
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/5/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import "Objective.h"

@interface Objective ()


@end

@implementation Objective
@dynamic name;
@dynamic imageURL;
@dynamic info;
@dynamic category;
@dynamic completed;
@dynamic messageSent;
//@dynamic location;
@dynamic range;
@dynamic latitude;
@dynamic longitude;



+(void)load{
    [self registerSubclass];
    
}

+(NSString *)parseClassName{
    return @"Objective";
}



+(instancetype)initWith: (NSString *)name imageURL:(NSString *)imageURL info:(NSString *)info category: (NSString *)category range: (NSNumber *)range latitude:(double)lat longitude:(double)lon{

    Objective *newObjective = [[Objective alloc]init];
    newObjective.name = name;
    newObjective.imageURL = imageURL;
    newObjective.info = info;
    newObjective.category = category;
    newObjective.completed = NO;
    newObjective.messageSent = NO;
    //newObjective.location = [[CLLocation alloc]initWithLatitude:lat longitude:lon];
    newObjective.latitude = lat;
    newObjective.longitude = lon;

    return newObjective;
}

+ (double)totalDistanceCrowFlies:(NSMutableArray *)objectives {
    double totalDistance = 0.00;
    for (int i = 1; i < objectives.count; i++) {
        Objective *first = [objectives objectAtIndex:(i-1)];
        Objective *second = [objectives objectAtIndex:(i)];
        CLLocation *firstLocation =  [[CLLocation alloc]initWithLatitude:first.latitude longitude:first.longitude];
        CLLocation *secondLocation =  [[CLLocation alloc]initWithLatitude:second.latitude longitude:second.longitude];
        
        totalDistance += [firstLocation distanceFromLocation:secondLocation];
    }
    return totalDistance;
}

+ (NSMutableArray *)randomizeObjectives:(NSMutableArray *)originalRoute {
    NSMutableArray *newObjective = [[NSMutableArray alloc]init];
    NSMutableArray *objectivesCopy = [originalRoute mutableCopy];
    
    while (objectivesCopy.count > 1) {
        int index = (int)(arc4random() * objectivesCopy.count % ( objectivesCopy.count - 1 ));
        [newObjective addObject:[objectivesCopy objectAtIndex:index]];
        [objectivesCopy removeObjectAtIndex:index];
    }
    [newObjective addObject:objectivesCopy.lastObject];
    return newObjective;
}

+ (NSMutableArray *)verifyDistanceRange:(NSMutableArray *)originalObjectives players:(int)players{
    
    NSMutableArray *fairObjectives = [[NSMutableArray alloc]init];
    double averageDistance = 0;
    int othercount = 0;
    for (int i = 0; i < 15; i++) {
        averageDistance += [self totalDistanceCrowFlies:[self randomizeObjectives:originalObjectives]];
        othercount ++;
    }
    
    averageDistance = averageDistance/15;
    NSLog(@"%d and average: %f", othercount, averageDistance);
    int counter = 0;
    while (fairObjectives.count < players) {
        counter ++;
        NSMutableArray *randomObjective = [self randomizeObjectives:originalObjectives];
        if (averageDistance * 0.925 < [self totalDistanceCrowFlies:randomObjective] && averageDistance * 1.075 > [self totalDistanceCrowFlies:randomObjective] && counter < 30) {
            [fairObjectives addObject:randomObjective];
        } else if (averageDistance * 0.85 < [self totalDistanceCrowFlies:randomObjective] && averageDistance * 1.15 > [self totalDistanceCrowFlies:randomObjective] && counter > 30) {
            [fairObjectives addObject:randomObjective];
        }
    }
    //FOR TESTING PURPOSES.. CAN BE DELETED IF TEST ARE DONE AND IT WORKS
    int count = 1;
    for (NSMutableArray *objective in fairObjectives) {
        NSLog(@"Player %i,: %f", count, [self totalDistanceCrowFlies:objective]);
        count ++;
    }
    return fairObjectives;
}


@end
