//
//  AppDelegate.m
//  UMBus
//
//  Created by Jonah Grant on 12/1/13.
//  Copyright (c) 2013 Jonah Grant. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "AppDelegate.h"
#import "DataStore.h"
#import "TTTLocationFormatter.h"
#import "LocationManager.h"
#import "Constants.h"

@implementation AppDelegate

+ (instancetype)sharedInstance {
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GMSServices provideAPIKey:kKeyGoogleMapsAPI];
    
    [[DataStore sharedManager] fetchArrivalsWithErrorBlock:^(NSError *error) {}];
    [[DataStore sharedManager] fetchAnnouncementsWithErrorBlock:^(NSError *error){}];
    
    // as long as we have stops, we don't need to reload them until the user requests it
    if ([[DataStore sharedManager] persistedStops] == nil) {
        [[DataStore sharedManager] fetchStopsWithErrorBlock:^(NSError *error) {}];
    }
    
    [[LocationManager sharedManager] fetchLocation];

    self.locationFormatter = [[TTTLocationFormatter alloc] init];
    [self.locationFormatter.numberFormatter setMaximumSignificantDigits:1];
    [self.locationFormatter setUnitSystem:TTTImperialSystem];
    
    return YES;
}

@end
