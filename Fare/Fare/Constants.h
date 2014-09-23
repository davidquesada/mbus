//
//  Constants.h
//  Fare
//
//  Created by Jonah Grant on 12/5/13.
//  Copyright (c) 2013 Jonah Grant. All rights reserved.
//

#pragma API Root

static NSString * kUMRootURL                    = @"http://mbus.doublemap.com/";

#pragma Legacy XML API

//static NSString * kUMAPIFetchArrivals           = @"shared/public_feed.xml";

// Not needed anymore.
//static NSString * kUMAPIFetchTraceRoute         = @"shared/map_trace_route_%@.xml";

#pragma JSON API

static NSString * kUMAPIFetchAnnouncements      = @"map/v2/announcements";
static NSString * kUMAPIFetchRoutes             = @"map/v2/routes";
static NSString * kUMAPIFetchStops              = @"map/v2/stops";
static NSString * kUMAPIFetchBuses              = @"map/v2/buses";

// What's the difference between a route and an arrival?
static NSString * kUMAPIFetchArrivals           = @"map/v2/routes";

static NSString * kUMAPIFetchETAFormat          = @"map/v2/eta?stop=%d";

#pragma Tags

static NSString * kError                        = @"error";
static NSString * kResponse                     = @"response";
static NSString * kXMLName                      = @"__name";
static NSString * kLiveFeed                     = @"livefeed";
static NSString * kRoute                        = @"route";
static NSString * kItem                         = @"item";
static NSString * kHistoricalData               = @"histdata";