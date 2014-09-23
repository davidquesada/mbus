//
//  Arrival.m
//  Fare
//
//  Created by Jonah Grant on 12/5/13.
//  Copyright (c) 2013 Jonah Grant. All rights reserved.
//

#import "Arrival.h"
#import "ArrivalStop.h"
#import "TraceRoute.h"
#import "Fare+UIColor.h"

@implementation Arrival

#pragma mark - NSValueTransformer

+ (NSValueTransformer *)routeColorJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *color) {
        return [UIColor colorFromHexString:color];
    } reverseBlock:^id(UIColor *color) {
        return [UIColor hexStringFromUIColor:color];
    }];
}

+ (NSValueTransformer *)traceRouteJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSArray *coords) {
        
        NSMutableArray *route = [[NSMutableArray alloc] initWithCapacity:coords.count];
        NSValueTransformer *transform = [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[TraceRoute class]];
        
        id dict = [NSMutableDictionary new];
        
        for (int i = 0; i < coords.count; i += 2)
        {
            CLLocationDegrees lat = [coords[i]   doubleValue];
            CLLocationDegrees lon = [coords[i+1] doubleValue];
            
            dict[@"latitude"] = @(lat);
            dict[@"longitude"] = @(lon);
            dict[@"sequenceNumber"] = [@(i >> 1) description];
            
            // Think of all the useless allocations we did just to move the coordinate pairs!
            TraceRoute *rt = [transform transformedValue:dict];
            [route addObject:rt];
        }
        
        return route;
        
    } reverseBlock:^id(id x) {
        @throw @"Not Implemented";
    }];
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"topOfLoop" : @"topofloop",
             @"routeColor" : @"color",
             
             @"traceRoute" : @"path",
             
             };
}

#pragma mark - NSObjet

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"Name: %@\nID: %@\ntopOfLoop: %@\nRoute color: %@\nStops: %@", self.name, self.id, self.topOfLoop, self.routeColor, self.stops];
}

@end
