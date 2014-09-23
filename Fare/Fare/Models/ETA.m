//
//  ETA.m
//  Fare
//
//  Created by David Quesada on 7/5/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "ETA.h"

@interface ETA ()

@property NSArray *internalData;

@property NSNumber *stopID;
@property (nonatomic, readwrite) NSDictionary *firstArrival;
@property (nonatomic, readwrite) NSDictionary *secondArrival;

@end

@implementation ETA

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{ @"internalData" : @"etas" };
}

+ (NSValueTransformer *)internalDataJSONTransformer
{
    return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *data) {
        
        id stopID, first, second;
        
        stopID = data.allKeys[0];
        first = [NSMutableDictionary new];
        second = [NSMutableDictionary new];
        
        NSArray *arrivals = data[data.allKeys[0]][@"etas"];
        
        for (NSDictionary *arrival in arrivals)
        {
            // Some etas are of type "scheduled" and can have huge avg values.
            if (![arrival[@"type"] isEqualToString:@"live"])
                continue;
            
            id route = arrival[@"route"];
            id time = arrival[@"avg"]; // time in minutes.
            
            // The etas are in order (probably) so that the first value encountered
            // is a smaller value, representing the next bus.
            if (!first[route])
                first[route] = time;
            else if (!second[route])
                second[route] = time;
        }
        
        return @[ stopID, first, second ];
    }];
}

- (NSArray *)internalData { return nil; }
- (void)setInternalData:(NSArray *)internalData
{
    self.stopID = internalData[0];
    self.firstArrival = internalData[1];
    self.secondArrival = internalData[2];
}

@end
