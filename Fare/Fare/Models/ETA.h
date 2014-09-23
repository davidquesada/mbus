//
//  ETA.h
//  Fare
//
//  Created by David Quesada on 7/5/14.
//  Copyright (c) 2014 David Quesada. All rights reserved.
//

#import "Mantle.h"

@interface ETA : MTLModel<MTLJSONSerializing>

@property (nonatomic, readonly) NSDictionary *firstArrival;
@property (nonatomic, readonly) NSDictionary *secondArrival;

@end
