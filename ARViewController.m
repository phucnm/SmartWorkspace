//
//  ARViewController.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/22/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "ARViewController.h"
#import "ARKit.h"
#import "MarkerView.h"
@interface ARViewController () <ARLocationDelegate, ARDelegate, ARMarkerDelegate, MarkerViewDelegate>



@property (nonatomic, strong) AugmentedRealityController *arController;
@property (nonatomic, strong) NSMutableArray *geoLocations;

@end

@implementation ARViewController
- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTouchMarkerView:(MarkerView *)markerView {
    
}

- (void)didUpdateHeading:(CLHeading *)newHeading {
    
}

-(void)didUpdateLocation:(CLLocation *)newLocation {
    NSLog(@"%@", newLocation.description);
}

-(void)didUpdateOrientation:(UIDeviceOrientation)orientation {
    
}

-(void)didTapMarker:(ARGeoCoordinate *)coordinate {
    NSLog(@"%d", coordinate._id);
}

-(NSMutableArray *)geoLocations {
    if(!_geoLocations) {
        [self generateGeoLocations];
    }
    return _geoLocations;
}

-(void)locationClicked:(ARGeoCoordinate *)coordinate {
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self geoLocations];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(!self.arController) {
        self.arController = [[AugmentedRealityController alloc] initWithView:[self view] parentViewController:self withDelgate:self];
    }
    
    [self.arController setMinimumScaleFactor:0.5];
    [self.arController setScaleViewsBasedOnDistance:YES];
    [self.arController setRotateViewsBasedOnPerspective:YES];
    [self.arController setDebugMode:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)generateGeoLocations {
    //1
    self.geoLocations = [NSMutableArray arrayWithCapacity:[self.workSpaces count]];
//    NSArray *lats = @[@10.83, @10.79, @10.82];
//    NSArray *lons = @[@106.8, @106.78, @106.68];
//    NSArray *titles = @[@"hehe", @"hoho", @"haha"];
    for (int i = 0; i < [self.workSpaces count]; i++) {
        WorkSpaceModel *ws          = [self.workSpaces objectAtIndex:i];
        double lat                  = ws.lat;
        double lon                  = ws.lon;
        NSString *title             = ws.name;
        UIImage *image              = [UIImage imageNamed:[[Utility getImagesPath] stringByAppendingPathComponent:ws.thumb_path]];
        CLLocation *location        = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        ARGeoCoordinate *coordinate = [ARGeoCoordinate coordinateWithLocation:location locationTitle:title andImage:image andId:ws.id];
        [coordinate calibrateUsingOrigin:[self.userLocation location]];
        
        MarkerView *markerView = [[MarkerView alloc] initWithCoordinate:coordinate delegate:self];
        markerView.ws = ws;
        [coordinate setDisplayView:markerView];
        
        //5
        [_arController addCoordinate:coordinate];
        [_geoLocations addObject:coordinate];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
