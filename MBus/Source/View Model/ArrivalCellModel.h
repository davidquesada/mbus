//
//  ArrivalCellModel.h
//  UMBus
//
//  Created by Jonah Grant on 12/7/13.
//  Copyright (c) 2013 Jonah Grant. All rights reserved.
//

@class Stop, Arrival;

@interface ArrivalCellModel : NSObject

@property (strong, nonatomic) Stop *stop;
@property (strong, nonatomic) Arrival *arrival;

- (instancetype)initWithStop:(Stop *)stop forArrival:(Arrival *)arrival;

- (NSString *)abbreviatedFirstArrivalString;
- (NSString *)formattedTimesOfArrival;

@end
