//
//  MapsViewController.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/22/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "MapsViewController.h"
#import "JPSThumbnailAnnotation.h"
@interface MapsViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic  ) IBOutlet UISegmentedControl *mapTypeSegment;
@property (weak, nonatomic  ) IBOutlet MKMapView          *mapView;
@property (strong, nonatomic) CLLocationManager  *locationManager;
@property (strong, nonatomic) NSMutableArray     *arrLocations;
@property (strong, nonatomic) MKUserLocation     *location;
@end

@implementation MapsViewController

#define METERS_PER_MILE 1609.344
- (IBAction)mapTypeChanged:(id)sender {
    if (self.mapTypeSegment.selectedSegmentIndex == 0)
        self.mapView.mapType = MKMapTypeStandard;
    else if (self.mapTypeSegment.selectedSegmentIndex == 1)
        self.mapView.mapType = MKMapTypeSatellite;
    else
        self.mapView.mapType = MKMapTypeHybrid;
}

- (IBAction)defineLocation:(id)sender {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.location.coordinate, 1200, 1200);
//    self.location = userLocation;
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];

}
- (IBAction)backtoWS:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView.delegate = self;
    
    [self populateAnnotations];
    

//    WSAnnotation *anno1 = [[WSAnnotation alloc] initWithTitle:@"hehe" AndCoordinate:CLLocationCoordinate2DMake(10.843, 106.635)];
//    WSAnnotation *anno2 = [[WSAnnotation alloc] initWithTitle:@"hoho" AndCoordinate:CLLocationCoordinate2DMake(10.845, 106.633)];
//    
//    [self.arrLocations addObject:anno1];
//    [self.arrLocations addObject:anno2];
//    
//    [self.mapView addAnnotation:anno1];
//    [self.mapView addAnnotation:anno2];
//    
//    self.locationManager = [[CLLocationManager alloc] init];
//    [self.locationManager setDelegate:self];
//    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
//    [self.locationManager requestAlwaysAuthorization];
//    [self.locationManager startUpdatingLocation];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) populateAnnotations {
    for (WorkSpaceModel *ws in self.workSpaces) {
        JPSThumbnail *thumbnail   = [[JPSThumbnail alloc] init];
        thumbnail.image           = [UIImage imageNamed:[[Utility getImagesPath] stringByAppendingPathComponent:ws.thumb_path]];
        thumbnail.title           = ws.name;
        //thumbnail.subtitle = @"NYC Landmark";
        thumbnail.coordinate      = CLLocationCoordinate2DMake(ws.lat, ws.lon);
        thumbnail.disclosureBlock = ^{
            
        };
        
        [self.mapView addAnnotation:[JPSThumbnailAnnotation annotationWithThumbnail:thumbnail]];
    }
}

#pragma mark - Map view delegates

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //NSLog(@"%@", [userLocation location]);
    if (!self.location) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
        self.location = userLocation;
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:NO];
        
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //1
    CLLocation *lastLocation = [locations lastObject];
//    
//    //2
    CLLocationAccuracy accuracy = [lastLocation horizontalAccuracy];
//    NSLog(@"Received location %@ with accuracy %f", lastLocation, accuracy);
    
    //3
    if(accuracy < 100.0) {
        //4
//        MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
//        MKCoordinateRegion region = MKCoordinateRegionMake([lastLocation coordinate], span);
//        
//        [self.mapView setRegion:region animated:YES];
//        
//        // More code here
//        
//        [self.mapView addAnnotations:self.arrLocations];
//        
//        [self zoomToLocation];
        
        [manager stopUpdatingLocation];
    }
}

- (void)zoomToLocation
{
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 10.84345516;
    zoomLocation.longitude= 106.63571825;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 7.5*METERS_PER_MILE,7.5*METERS_PER_MILE);
    [self.mapView setRegion:viewRegion animated:YES];
    
    [self.mapView regionThatFits:viewRegion];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ARViewController *arView = [segue destinationViewController];
    arView.userLocation      = [self.mapView userLocation];
    arView.workSpaces        = self.workSpaces;
}

@end
