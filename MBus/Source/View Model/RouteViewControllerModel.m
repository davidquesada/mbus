//
//  RouteViewControllerModel.m
//  UMBus
//
//  Created by Jonah Grant on 12/19/13.
//  Copyright (c) 2013 Jonah Grant. All rights reserved.
//

#import "RouteViewControllerModel.h"
#import "Arrival.h"
#import "ArrivalStop.h"
#import "DataStore.h"
#import "TTTTimeIntervalFormatter.h"
#import "Constants.h"

@interface RouteViewControllerModel ()

@property (strong, nonatomic) TTTTimeIntervalFormatter *timeIntervalFormatter;

@end

@implementation RouteViewControllerModel

- (instancetype)initWithArrival:(Arrival *)arrival {
    if (self = [super init]) {
        self.arrival = arrival;
        self.timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];

        [[RACObserve([DataStore sharedManager], arrivals) filter:^BOOL(NSArray *arrivals) {
            return (arrivals.count > 0);
        }] subscribeNext:^(NSArray *arrivals) {
            Arrival *arrival = [[DataStore sharedManager] arrivalForID:self.arrival.id];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                self.sortedStops = [self stopsOrderedByTimeOfArrivalWithStops:arrival.stops];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.dataUpdatedBlock();
                });
            });
        }];
    }
    return self;
}

- (void)fetchData {
    [[DataStore sharedManager] fetchArrivalsWithErrorBlock:^(NSError *error) {
        self.dataUpdatedBlock();
    } requester:self];
}

- (NSArray *)stopsOrderedByTimeOfArrivalWithStops:(NSArray *)stopIDs
{
    NSArray *IDs = [self stopIDsOrderedByTimeOfArrivalWithStops:stopIDs];
    NSMutableArray *stops = [NSMutableArray new];
    
    for (NSNumber *sid in IDs)
    {
        [stops push:[[DataStore sharedManager] stopForID:sid]];
    }
    return stops;
}

- (NSArray *)stopIDsOrderedByTimeOfArrivalWithStops:(NSArray *)stops {
    return [stops sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {

        ArrivalStop *a = obj1;
        ArrivalStop *b = obj2;
        
#warning "How are we going to order these?"
        // For now, just do this. A and B are actually NSNumber.
        return [(NSNumber *)a compare:(id)b];
        
        
        if (a.timeOfArrival < b.timeOfArrival) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if (a.timeOfArrival > b.timeOfArrival) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
}

- (NSString *)mmssForTimeInterval:(NSTimeInterval)timeInterval {
    return [NSString stringWithFormat:@"%02i:%02i", ((NSInteger)timeInterval / 60) % 60, (NSInteger)timeInterval % 60];
}

- (NSString *)timeSinceLastRefresh {
    if (![[DataStore sharedManager] arrivalsTimestamp]) {
        return NEVER;
    }
    
    return [self.timeIntervalFormatter stringForTimeInterval:[[[DataStore sharedManager] arrivalsTimestamp] timeIntervalSinceDate:[NSDate date]]];
}

- (NSString *)footerString {
    return [NSString stringWithFormat:FORMATTED_AS_OF, [self timeSinceLastRefresh]];
}


@end
