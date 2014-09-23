//
//  Stop.m
//  Fare
//
//  Created by Jonah Grant on 12/1/13.
//  Copyright (c) 2013 Jonah Grant. All rights reserved.
//

#import "Stop.h"

@implementation Stop

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
//             @"uniqueName" : @"unique_name",
//             @"humanName" : @"human_name",
             @"humanName" : @"name",

             @"additionalName" : @"additional_name",
             
             @"latitude" : @"lat",
             @"longitude" : @"lon",
             
             };
}

#pragma mark - NSObject

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"ID: %@\nUnique name: %@\nHuman name: %@\nAdditional name: %@\nLatitude: %@\nLongitude: %@\nHeading: %@",
            self.id,
            self.uniqueName,
            self.humanName,
            self.additionalName,
            self.latitude,
            self.longitude,
            self.heading];
}

#pragma mark - Stop

- (NSString *)uniqueName
{
    return [self.id description];
}

@end
