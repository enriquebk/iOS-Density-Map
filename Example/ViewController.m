//
//  ViewController.m
//  GLDensityMap
//
//  Created by Enrique Bermúdez on 3/15/18.
//  Copyright © 2018 Enrique Bermúdez. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <GLDensityMap/GLDensityMap.h>

@interface ViewController ()

@property NSMutableArray<CLLocation *> *locations;
@property (weak, nonatomic) IBOutlet GLDensityMapView *densityMapView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Load example locations
    [self loadLocations];
    
    //Setup mapview region
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.locations.lastObject.coordinate, 20000, 20000)];//20km
    
    //Setup Desnity map
    [self setupDensityMapView];
}

#pragma mark -

- (void)setupDensityMapView{
    
    //Set the number of particles styles (style groups).
    self.densityMapView.styleGroupsCount = 1;
    
    //Retruns the style for each group.
    self.densityMapView.styleForStyleGroup = ^GLParticleStyle(GLStyleGroupIndex groupIndex) {
        GLParticleStyle style = {
            .radius = 7,
            .blurFactor = 0.95,
            .r = 255,
            .g = 130,
            .b = 0,
            .opacity = 0.45,
        };
        return style;
    };
    
    __weak ViewController *wself = self;
    
    //Retruns the number of particles for each group.
    self.densityMapView.particlesCountForStyleGroup = ^uint(GLStyleGroupIndex groupIndex) {
        return (int)wself.locations.count;
    };
    
    //Retruns the x,y position for each particle
    self.densityMapView.positionForParticle = ^CGPoint(GLParticleIndex pointIndex, GLStyleGroupIndex groupIndex) {
        return  [wself.mapView convertCoordinate:wself.locations[pointIndex].coordinate
                                   toPointToView:wself.view];
    };
}

#pragma mark -

- (void)loadLocations {
    
    self.locations = [[NSMutableArray alloc] init];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"places"
                                                     ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSArray *lines = [content componentsSeparatedByString:@"\n"];

    for (NSString *line in lines) {
        NSArray *parts = [line componentsSeparatedByString:@","];
        
        if (parts.count<2){
            break;
        }
        
        NSString *latStr = parts[0];
        NSString *lonStr = parts[1];
    
        [self.locations addObject:[[CLLocation alloc] initWithLatitude:[latStr doubleValue]
                                                             longitude:[lonStr doubleValue]]];
    }
}

@end
