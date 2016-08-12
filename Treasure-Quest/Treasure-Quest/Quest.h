//
//  Quest.h
//  Treasure-Quest
//
//  Created by Michael Sweeney on 8/4/16.
//  Copyright © 2016 Michael Sweeney. All rights reserved.
//

#import <Parse/Parse.h>
#import "Playfield.h"
#import "Player.h"
#import "Route.h"


@interface Quest : PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) Player *creator;
@property (strong, nonatomic) NSMutableArray *players;

@property (strong, nonatomic) NSNumber *maxplayers;
//@property (strong, nonatomic) Route *route;
@property (strong, nonatomic) NSMutableArray *objectives;
@property (strong, nonatomic) NSMutableArray *objectivesCompleted;
@property (strong, nonatomic) NSMutableArray *objectivesMessaged;

@end
