//
//  MapViewControllerModel.m
//  UMBus
//
//  Created by Jonah Grant on 12/20/13.
//  Copyright (c) 2013 Jonah Grant. All rights reserved.
//

#import "MapViewControllerModel.h"
#import "DataStore.h"
#import "Bus.h"
#import "BusAnnotation.h"

@implementation MapViewControllerModel

- (instancetype)init {
    if (self = [super init]) {
        [RACObserve([DataStore sharedManager], buses) subscribeNext:^(NSArray *buses) {
            if (buses) {
                self.buses = buses;
                
                if (self.fetchingContinuously)
                    [self fetchBuses];
            }
        }];
        
        [RACObserve(self, buses) subscribeNext:^(NSArray *buses) {
            if (buses) [self manageBusAnnotations];
        }];

    }
    return self;
}

- (void)refreshData {
    self.busAnnotations = nil;
    [self fetchBuses];
}

- (void)beginContinuousFetching {
    self.fetchingContinuously = YES;
    [self fetchBuses];
}

- (void)endContinuousFetching {
    self.fetchingContinuously = NO;
}

- (void)fetchBuses {
    [[DataStore sharedManager] fetchBusesWithErrorBlock:NULL];
}

- (void)manageBusAnnotations {
    NSMutableDictionary *mutableAnnotations = [NSMutableDictionary dictionaryWithDictionary:self.busAnnotations];
    for (Bus *bus in self.buses) {
        if ([self.busAnnotations objectForKey:bus.id]) {
            // OLD BUS: update it's properties
            [(BusAnnotation *)[mutableAnnotations objectForKey:bus.id] setCoordinate:CLLocationCoordinate2DMake([bus.latitude doubleValue], [bus.longitude doubleValue])];
            [(BusAnnotation *)[mutableAnnotations objectForKey:bus.id] setHeading:[bus.heading floatValue]];
        } else {
            // NEW BUS: create annotation and add to dictionary
            BusAnnotation *annotation = [[BusAnnotation alloc] initWithBus:bus];
            [mutableAnnotations addEntriesFromDictionary:@{bus.id : annotation}];
        }
    }
    self.busAnnotations = mutableAnnotations;
}

@end
