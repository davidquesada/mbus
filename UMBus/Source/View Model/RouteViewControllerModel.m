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

        [RACObserve([DataStore sharedManager], arrivals) subscribeNext:^(NSArray *arrivals) {
            if (arrivals) {
                Arrival *arrival = [[DataStore sharedManager] arrivalForID:self.arrival.id];
                self.sortedStops = [self stopsOrderedByTimeOfArrivalWithStops:arrival.stops];
            }
        }];
    }
    return self;
}

- (NSArray *)stopsOrderedByTimeOfArrivalWithStops:(NSArray *)stops {
    return [stops sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        ArrivalStop *a = obj1;
        ArrivalStop *b = obj2;
        
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
        return kNever;
    }
    
    return [self.timeIntervalFormatter stringForTimeInterval:[[[DataStore sharedManager] arrivalsTimestamp] timeIntervalSinceDate:[NSDate date]]];
}

- (NSString *)footerString {
    return [NSString stringWithFormat:kFormattedStringLastUpdated, [self timeSinceLastRefresh]];
}


@end