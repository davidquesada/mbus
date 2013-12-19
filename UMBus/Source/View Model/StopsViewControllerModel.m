//
//  StopsViewControllerModel.m
//  UMBus
//
//  Created by Jonah Grant on 12/18/13.
//  Copyright (c) 2013 Jonah Grant. All rights reserved.
//

#import "StopsViewControllerModel.h"
#import "LocationManager.h"
#import "DataStore.h"
#import "Stop.h"

@implementation StopsViewControllerModel

- (instancetype)init {
    if (self = [super init]) {
        
        // handle persisted data when the app initially launches
        if ([[DataStore sharedManager] persistedStops] && [[DataStore sharedManager] persistedLastKnownLocation]) {
            self.stops = [self sortedStopsByDistanceWithArray:[[DataStore sharedManager] persistedStops]
                                                     location:[[DataStore sharedManager] persistedLastKnownLocation]];
        } else if ([[DataStore sharedManager] persistedStops] && ![[DataStore sharedManager] persistedLastKnownLocation]) {
            self.stops = [[DataStore sharedManager] persistedStops];
        } else {
            self.stops = [NSArray array];
        }
        
        // handle incoming data
        [RACObserve([DataStore sharedManager], stops) subscribeNext:^(NSArray *stops) {
            if (stops) {
                if (([DataStore sharedManager].lastKnownLocation || [[DataStore sharedManager] persistedLastKnownLocation]) && [DataStore sharedManager].arrivals) {
                    self.stops = [self sortedStopsByDistanceWithArray:[[DataStore sharedManager] stopsBeingServicedInArray:stops]
                                                             location:([DataStore sharedManager].lastKnownLocation) ? [DataStore sharedManager].lastKnownLocation : [[DataStore sharedManager] persistedLastKnownLocation]];
                } else if ([DataStore sharedManager].arrivals && ![DataStore sharedManager].lastKnownLocation && ![[DataStore sharedManager] persistedLastKnownLocation]) {
                    self.stops = [[DataStore sharedManager] stopsBeingServicedInArray:stops];
                } else if (([DataStore sharedManager].lastKnownLocation || [[DataStore sharedManager] persistedLastKnownLocation]) && ![DataStore sharedManager].arrivals) {
                    self.stops = [self sortedStopsByDistanceWithArray:stops location:([DataStore sharedManager].lastKnownLocation) ? [DataStore sharedManager].lastKnownLocation : [[DataStore sharedManager] persistedLastKnownLocation]];
                } else {
                    self.stops = stops;
                }
            }
        }];
        
        [RACObserve([DataStore sharedManager], arrivals) subscribeNext:^(NSArray *arrivals) {
            if (arrivals) {
                if (([DataStore sharedManager].lastKnownLocation || [[DataStore sharedManager] persistedLastKnownLocation]) &&
                    ([DataStore sharedManager].stops || [[DataStore sharedManager] persistedStops])) {
                    self.stops = [self sortedStopsByDistanceWithArray:[[DataStore sharedManager] stopsBeingServicedInArray:([DataStore sharedManager].stops) ? [DataStore sharedManager].stops : [[DataStore sharedManager] persistedStops]]
                                                             location:([DataStore sharedManager].lastKnownLocation) ? [DataStore sharedManager].lastKnownLocation : [[DataStore sharedManager] persistedLastKnownLocation]];
                } else if (([DataStore sharedManager].stops || [[DataStore sharedManager] persistedStops])) {
                    NSArray *array = ([DataStore sharedManager].stops) ? [DataStore sharedManager].stops : [[DataStore sharedManager] persistedStops];
                    self.stops = [[DataStore sharedManager] stopsBeingServicedInArray:array];
                } else {
                    // if there aren't any stops on file, these arrivals are useless because we have no stops to compare them against
                }
            }
        }];
        
        [RACObserve([DataStore sharedManager], lastKnownLocation) subscribeNext:^(CLLocation *location) {
            if (location) {
                if (([DataStore sharedManager].stops || [[DataStore sharedManager] persistedStops]) && [DataStore sharedManager].arrivals) {
                    NSArray *array = ([DataStore sharedManager].stops) ? [DataStore sharedManager].stops : [[DataStore sharedManager] persistedStops];
                    self.stops = [self sortedStopsByDistanceWithArray:[[DataStore sharedManager] stopsBeingServicedInArray:array] location:location];
                } else if ([DataStore sharedManager].stops || [[DataStore sharedManager] persistedStops]) {
                    NSArray *array = ([DataStore sharedManager].stops) ? [DataStore sharedManager].stops : [[DataStore sharedManager] persistedStops];
                    self.stops = [self sortedStopsByDistanceWithArray:array location:location];
                }
            }
        }];
    }
    return self;
}

- (NSArray *)sortedStopsByDistanceWithArray:(NSArray *)array location:(CLLocation *)location {
    return [array sortedArrayUsingComparator:^(id a,id b) {
        Stop *stopA = a;
        Stop *stopB = b;
        
        CLLocation *aLocation = [[CLLocation alloc] initWithLatitude:[stopA.latitude doubleValue] longitude:[stopA.longitude doubleValue]];
        CLLocation *bLocation = [[CLLocation alloc] initWithLatitude:[stopB.latitude doubleValue] longitude:[stopB.longitude doubleValue]];
        
        CLLocationDistance distanceA = [aLocation distanceFromLocation:location];
        CLLocationDistance distanceB = [bLocation distanceFromLocation:location];
                
        if (distanceA < distanceB) {
            return NSOrderedAscending;
        } else if (distanceA > distanceB) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

- (void)fetchData {
    [[DataStore sharedManager] fetchStopsWithErrorBlock:^(NSError *error) {
        self.stops = self.stops;
    }];
}

@end
