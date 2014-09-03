//
//  MapViewController.m
//  MBus
//
//  Created by Jonah Grant on 3/1/14.
//  Copyright (c) 2014 Jonah Grant. All rights reserved.
//

@import MapKit;

#import "UMNetworkingSession.h"
#import "MapViewController.h"
#import "MapViewControllerModel.h"
#import "Constants.h"
#import "Bus.h"
#import "Arrival.h"
#import "Stop.h"
#import "ArrivalStop.h"
#import "TraceRoute.h"
#import "DataStore.h"
#import "BusAnnotation.h"
#import "CircleAnnotationView.h"

@interface MapViewController () <UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) UMNetworkingSession *networkingSession;
@property (nonatomic, strong, readwrite) MapViewControllerModel *model;
@property (nonatomic, strong, readwrite) IBOutlet MKMapView *mapView;
@property (nonatomic, strong, readwrite) Arrival *activeArrival;
@property (nonatomic, strong, readwrite) NSArray *activeArrivalAnnotations;

- (void)loadAnnotations;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.networkingSession = [[UMNetworkingSession alloc] init];

    self.model = [[MapViewControllerModel alloc] init];
    @weakify(self);
    self.model.dataUpdatedBlock = ^ {
        @strongify(self);
        [self loadAnnotations];
    };
    
    if (self.startingStop.coordinate.latitude != 0 && self.startingStop.coordinate.longitude != 0) {
        [self dropAndZoomToPinWithCoordinate:self.startingStop.coordinate];
        
        self.title = self.startingStop.humanName;
        
        if (self.arrivalIDsServicingStop.count == 1) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                self.activeArrival = [[DataStore sharedManager] arrivalForID:self.arrivalIDsServicingStop[0]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadTraceRouteForArrivalID:self.arrivalIDsServicingStop[0]];
                });
            });
        }
    } else {
        [self zoomToCampus];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.model beginContinuousFetching];
    [self resetInterface];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.model endContinuousFetching];
}

- (void)loadAnnotations {
    NSMutableArray *annotationArray = [NSMutableArray array];
    for (Bus *bus in [DataStore sharedManager].buses) {
        BusAnnotation *annotation = [self.model.busAnnotations objectForKey:bus.id];
        
        if (self.startingStop != nil) {
            for (NSString *routeID in self.arrivalIDsServicingStop) {
                Arrival *arrival = [[DataStore sharedManager] arrivalForID:bus.routeID];
                if ([routeID isEqual:arrival.id]) {
                    [self.mapView addAnnotation:annotation];
                    [annotationArray addObject:annotation];
                }
            }
        } else {
            [self.mapView addAnnotation:annotation];
            [annotationArray addObject:annotation];
        }
    }
    
    // remove buses no longer in service
    NSMutableArray *intermediate = [NSMutableArray arrayWithArray:self.mapView.annotations];
    for (int i = 0, j = (int)self.mapView.annotations.count; i < j; i++) {
        if ([intermediate[i] isKindOfClass:[MKPointAnnotation class]]) {
            [intermediate removeObject:intermediate[i]];
            break;
        }
    }
    
    [intermediate removeObjectsInArray:annotationArray];
    [intermediate removeObjectsInArray:self.activeArrivalAnnotations];
    [self.mapView removeAnnotations:intermediate];
}

- (void)zoomToCampus {
    MKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(CAMPUS_CENTER_LAT, CAMPUS_CENTER_LNG);
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    region.span = span;
    
    [self.mapView setRegion:region animated:YES];
}

- (void)zoomToTopOverlay {
    [self.mapView setVisibleMapRect:[self.mapView.overlays[0] boundingMapRect]
                        edgePadding:UIEdgeInsetsMake(20, 20, 20, 20)
                           animated:NO];
}

- (void)dropAndZoomToPinWithCoordinate:(CLLocationCoordinate2D)coordinate {
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    [_mapView addAnnotation:annotation];
    
    MKMapCamera *camera = [MKMapCamera new];
    camera.centerCoordinate = coordinate;
    camera.heading = 0;
    camera.pitch = 0;
    camera.altitude = 5000;
    [self.mapView setCamera:camera animated:NO];
}

- (void)loadTraceRouteForArrivalID:(NSString *)arrivalID {
    [self.mapView removeOverlays:self.mapView.overlays];

    
    dispatch_async(dispatch_get_main_queue(), ^{
        Arrival *arrival = [[DataStore sharedManager] arrivalForID:arrivalID];
        MKPolyline *polyline = [self polylineFromTraceRoute:arrival.traceRoute];
        [self.mapView addOverlay:polyline];
        
//        if (self.arrivalIDsServicingStop.count > 1) {
//            [self zoomToTopOverlay];
//        }
    });
}

- (MKPolyline *)polylineFromTraceRoute:(NSArray *)traceRoute {
    CLLocationCoordinate2D coordinates[traceRoute.count];
    
    for (int i = 0, n = (int)traceRoute.count; i < n; i++) {
        TraceRoute *route = traceRoute[i];
        coordinates[i] = route.coordinate;
    }
    
    return [MKPolyline polylineWithCoordinates:coordinates count:traceRoute.count];
}

- (void)resetActiveArrival {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self zoomToCampus];
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.mapView removeAnnotations:self.activeArrivalAnnotations];
    });
}

#pragma mark MKMapView delegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } else if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier: @"annotation_ID"];
        if (pin == nil) {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"annotation_ID"];
        } else {
            pin.annotation = annotation;
        }
        
        pin.pinColor = MKPinAnnotationColorRed;
        pin.animatesDrop = (self.startingStop.coordinate.latitude != 0 && self.startingStop.coordinate.longitude != 0) ? YES : NO;
        pin.canShowCallout = YES;
        
        return pin;
    } else if ([annotation isKindOfClass:[BusAnnotation class]]) {
        BusAnnotation *_annotation = (BusAnnotation *)annotation;
        CircleAnnotationView *pin = [[CircleAnnotationView alloc] initWithAnnotation:_annotation
                                                                     reuseIdentifier:@"Pin"
                                                                               color:_annotation.color
                                                                        outlineColor:[UIColor whiteColor]];
        pin.canShowCallout = YES;
        
        return pin;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[BusAnnotation class]] && [(BusAnnotation *)view.annotation arrival].id != self.activeArrival.id) {
        self.activeArrival = [(BusAnnotation *)view.annotation arrival];
        [self loadTraceRouteForArrivalID:self.activeArrival.id];
    }
}

#pragma MKMapView

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = self.activeArrival.routeColor;
    renderer.lineWidth = 6.0;
    renderer.alpha = 0.8;
    
    return renderer;
}

@end
