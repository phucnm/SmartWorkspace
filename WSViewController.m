//
//  WSViewController.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/26/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "WSViewController.h"
#import "WorkSpaceTableView.h"
#import <SWTableViewCell.h>
#import <SWTableViewCell/NSMutableArray+SWUtilityButtons.h>
#import "ARViewController.h"
#import "JPSThumbnailAnnotation.h"

@interface WSViewController () <CLLocationManagerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, SWTableViewCellDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>

//@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) NSMutableArray *arrWorkspaces;
@property (nonatomic, strong) CLLocationManager *clManager;
@property (nonatomic, strong) WorkSpaceManager *wsManager;
@property (nonatomic, strong) MKUserLocation *location;
@property (weak, nonatomic) IBOutlet WorkSpaceTableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeSegment;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (strong, nonatomic) NSMutableArray *annotations;
@end

@implementation WSViewController
CLGeocoder *geocoder;
CLPlacemark *placemark;

-(void)dealloc {
    self.tableView.emptyDataSetSource = nil;
    self.tableView.emptyDataSetDelegate = nil;
    self.clManager.delegate = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.tableFooterView = [UIView new];
    
    self.mapView.delegate = self;
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMapView:)];
    [self.mapView addGestureRecognizer:tapGR];
    [self populateAnnotations];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(barButtonClicked)];
    //    UIBarButtonItem *mapViewButton = [UIBarButtonItem alloc
    //    self.navigationItem.rightBarButtonItem = barButton;
    
    //    AppDelegate *delegate = [AppDelegate sharedDelegate];
    //    self.db = delegate.db;
    //
    //    if ([self.db open]) {
    //        self.arrWorkspaces = [NSMutableArray array];
    //        FMResultSet *result = [self.db executeQuery:@"SELECT * FROM WORKSPACES"];
    //        while ([result next]) {
    //            WorkSpaceModel *model = [[WorkSpaceModel alloc] init];
    //            model.id = [result intForColumn:@"_id"];
    //            model.name = [result stringForColumn:@"name"];
    //            model.image_path = [result stringForColumn:@"image_path"];
    //            model.thumb_path = [result stringForColumn:@"thumb_path"];
    //            model.lon = [result doubleForColumn:@"lon"];
    //            model.lat = [result doubleForColumn:@"lat"];
    //            //model.address = [result stringForColumn:@"address"];
    //            [self.arrWorkspaces addObject:model];
    //        }
    //        [self.db close];
    //    }
    self.arrWorkspaces = [[[WorkSpaceManager sharedManager] selectAll] mutableCopy];
    
    // Initialize the refresh control.
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(getLatestData:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    
    
    self.clManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    self.clManager.delegate = self;
    self.clManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.clManager requestWhenInUseAuthorization];
    [self.clManager startUpdatingLocation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

int bigMap = NO;

-(void) didTapMapView:(UIGestureRecognizer *) gr {
    if (gr.state != UIGestureRecognizerStateEnded)
        return;

    [UIView animateWithDuration:0.5f animations:^{
        if (!bigMap) {
            
            [self.mapView setFrame:CGRectMake(self.mapView.frame.origin.x, self.mapView.frame.origin.y, self.mapView.frame.size.width, 568-49-44)];
            
        } else {
            

            [self.mapView setFrame:CGRectMake(self.mapView.frame.origin.x, self.mapView.frame.origin.y, self.mapView.frame.size.width, 200)];
            
        }
        [UIView animateWithDuration:0.1f animations:^{
            if (!bigMap)
                [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, 1000, self.tableView.frame.size.width, self.tableView.frame.size.height)];
            else
                [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x, 0, self.tableView.frame.size.width, self.tableView.frame.size.height)];
        }];

    }];
    
    [UIView animateWithDuration:0.3f animations:^{
        if (!bigMap) {
            [self.mapTypeSegment setFrame:CGRectMake(self.mapTypeSegment.frame.origin.x, self.mapView.frame.size.height - 10 , self.mapTypeSegment.frame.size.width, self.mapTypeSegment.frame.size.height)];
            [self.locationButton setFrame:CGRectMake(self.locationButton.frame.origin.x, self.mapView.frame.size.height - 15, self.locationButton.frame.size.width, self.locationButton.frame.size.height)];
        } else {
            [self.mapTypeSegment setFrame:CGRectMake(self.mapTypeSegment.frame.origin.x, 225, self.mapTypeSegment.frame.size.width, self.mapTypeSegment.frame.size.height)];
            [self.locationButton setFrame:CGRectMake(self.locationButton.frame.origin.x, 220, self.locationButton.frame.size.width, self.locationButton.frame.size.height)];
            [self.tableView setHidden:NO];
        }
    }];
        bigMap = ~bigMap;
}

-(void) populateAnnotations {
    self.annotations = [NSMutableArray array];
    for (WorkSpaceModel *ws in self.arrWorkspaces) {
        JPSThumbnail *thumbnail = [[JPSThumbnail alloc] init];
        thumbnail.image = [UIImage imageNamed:[[Utility getImagesPath] stringByAppendingPathComponent:ws.thumb_path]];
        thumbnail.title = ws.name;
        //thumbnail.subtitle = @"NYC Landmark";
        thumbnail.coordinate = CLLocationCoordinate2DMake(ws.lat, ws.lon);
        thumbnail.disclosureBlock = ^{ NSLog(@"selected"); };
        
        [self.mapView addAnnotation:[JPSThumbnailAnnotation annotationWithThumbnail:thumbnail]];
        [self.annotations addObject:thumbnail];
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
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        
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

-(void) getLatestData:(UIRefreshControl*) refreshCtrl {
    [self.tableView reloadData];
    [refreshCtrl endRefreshing];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.contentInset = UIEdgeInsetsMake(self.mapView.frame.size.height+60, 0, 0, 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.contentOffset.y < self.mapView.frame.size.height*-1 - 60 ) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, self.mapView.frame.size.height*-1)];
//        scrollView.contentOffset = CGPointMake(0.0f, -40.0f);
    }
}

#pragma mark - Empty table delegate

-(UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"ws_empty"];
}

-(UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIColor colorWithRed:230 green:230 blue:230 alpha:0.8];
}

#pragma mark - WSCreate delegate
-(void)didCreatedWS:(WorkSpaceModel *)ws {
    [self.arrWorkspaces insertObject:ws atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
}

#pragma mark - Prepare segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"createWS"]) {
        WSCreateViewController *wsCreate = (WSCreateViewController*)[segue destinationViewController];
        wsCreate.workSpaces = self.arrWorkspaces;
        //wsCreate.delegate = self;
    } else {
        ARViewController *arView = [segue destinationViewController];
        arView.userLocation = [self.mapView userLocation];
        arView.workSpaces = self.arrWorkspaces;
    }

}

#pragma mark - Bar button item

- (void)barButtonClicked {
    
}

#pragma mark - Swipe Cell

-(void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    if (index == 0) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        WorkSpaceModel *ws = (WorkSpaceModel*)self.arrWorkspaces[indexPath.row];
        NSString *name = ws.name;
        
        
        //delete from table
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //delete from sql
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            if ([[WorkSpaceManager sharedManager] deleteOneWithName:name]) {
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:[[Utility getImagesPath] stringByAppendingPathComponent:ws.image_path] error:&error];
                [[NSFileManager defaultManager] removeItemAtPath:[[Utility getImagesPath] stringByAppendingPathComponent:ws.thumb_path] error:&error];
                [self.arrWorkspaces removeObjectAtIndex:indexPath.row];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
        
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"Failed to Get Your Location"
                                                         delegate:nil cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    [alertView show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //    NSLog(@"didUpdateToLocation: %@", newLocation);
    //    CLLocation *currentLocation = newLocation;
    //    NSLog(@"%f", [currentLocation horizontalAccuracy]);
    if ([newLocation horizontalAccuracy] < 100) {
        [self.arrWorkspaces sortUsingComparator:^NSComparisonResult(WorkSpaceModel *obj1, WorkSpaceModel *obj2) {
            CLLocation *first = [[CLLocation alloc] initWithLatitude:obj1.lat longitude:obj1.lon];
            CLLocation *second = [[CLLocation alloc] initWithLatitude:obj2.lat longitude:obj2.lon];
            CLLocationDistance d1 = [newLocation distanceFromLocation:first];
            CLLocationDistance d2 = [newLocation distanceFromLocation:second];
            if (d1 < d2) {
                return NSOrderedAscending;
            }
            if (d1 > d2) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
        
        NSLog(@"%@", @"Stop update location");
        [self.clManager stopUpdatingLocation];
    }
    
    //    if (currentLocation != nil) {
    //        NSLog(@"%@",[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude]);
    //        NSLog(@"%@",[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude]);
    //    }
    //
    //    NSLog(@"Resolving the Address");
    //    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
    //        NSLog(@"Finding address");
    //        if (error) {
    //            NSLog(@"Error %@", error.description);
    //        } else {
    //            CLPlacemark *placemark = [placemarks lastObject];
    //            NSLog(@"%@", placemark);
    //        }
    //    }];
    
}

#pragma mark - Swipe table view cell

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    //    [rightUtilityButtons sw_addUtilityButtonWithColor:
    //     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
    //                                                title:@"Details"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.arrWorkspaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WorkSpaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wsTableViewCell" forIndexPath:indexPath];
    
    WorkSpaceModel *model = [self.arrWorkspaces objectAtIndex:indexPath.row];
    
    //NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    cell.thumbView.image = [UIImage imageWithContentsOfFile:[[Utility getImagesPath] stringByAppendingPathComponent:model.thumb_path]];
    cell.nameLb.text = model.name;
    //cell.addrLb.text = model.address;
    
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WorkSpaceTableViewCell *ws = (WorkSpaceTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"self.title == %@", ws.nameLb.text];
    NSArray *res = [self.annotations filteredArrayUsingPredicate:resultPredicate];
    [self.mapView selectAnnotation:[res firstObject] animated:NO];
//    WorkSpaceModel *ws = [self.arrWorkspaces objectAtIndex:indexPath.row];
//    WSPopupViewController *popup = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"popup"];
//    popup.ws = ws;
//    popup.view.frame = CGRectMake(0, 0, 320, 450);
//    [self presentPopUpViewController:popup];
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 
 WorkSpaceModel *ws = [self.arrWorkspaces objectAtIndex:indexPath.row];
 [[WorkSpaceManager sharedManager] deleteOneWithName:ws.name];
 
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
