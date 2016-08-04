//
//  Playfield.h
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/4/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import <Parse/Parse.h>

@interface Playfield : PFObject<PFSubclassing>

@property (strong, nonatomic) PFGeoPoint *coordinate;
@property (strong, nonatomic) NSNumber *minRadius;
@property (strong, nonatomic) NSNumber *maxRadius;

@end
