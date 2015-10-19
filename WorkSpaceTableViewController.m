//
//  WorkSpaceTableViewController.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/17/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "WorkSpaceTableViewController.h"
#import <SWTableViewCell.h>
#import <SWTableViewCell/NSMutableArray+SWUtilityButtons.h>

@interface WorkSpaceTableViewController () <CLLocationManagerDelegate, WSCreateDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, SWTableViewCellDelegate, UIAlertViewDelegate>
//@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) NSMutableArray    *arrWorkspaces;
@property (nonatomic, strong) NSArray           *searchResults;
@property (nonatomic, strong) CLLocationManager *clManager;
@property (nonatomic, strong) WorkSpaceManager  *wsManager;
@property (nonatomic, strong) CLLocation        *location;

@end

@implementation WorkSpaceTableViewController
CLGeocoder *geocoder;
CLPlacemark *placemark;

-(void)dealloc {
    self.tableView.emptyDataSetSource = nil;
    self.tableView.emptyDataSetDelegate = nil;
    self.clManager.delegate = nil;
}

-(void) simulateDB {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Simulate devices" message:@"Choose a DB file" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"db1", @"db2", @"db3", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
        return;
    WorkSpaceManager *wsm = [WorkSpaceManager sharedManager];
    NSString *file = [NSString stringWithFormat:@"%@%ld", @"db", (long)buttonIndex];
    NSString *fileName = [file stringByAppendingString:@".sqlite"];
    [AppDelegate sharedDelegate].simulateMode = file;
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dbInDocumentPath = [documentsPath stringByAppendingPathComponent:fileName];
    
    wsm.db = [FMDatabase databaseWithPath:dbInDocumentPath];
    self.arrWorkspaces = [[wsm selectAll] mutableCopy];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadLocation];
}

- (void)reloadLocation {
    //[self.clManager startUpdatingLocation];
    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock timeout:20 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        switch (status) {
            case INTULocationStatusSuccess: {
                self.location = currentLocation;
                [self.arrWorkspaces sortUsingComparator:^NSComparisonResult(WorkSpaceModel *obj1, WorkSpaceModel *obj2) {
                    CLLocation *first     = [[CLLocation alloc] initWithLatitude:obj1.lat longitude:obj1.lon];
                    CLLocation *second    = [[CLLocation alloc] initWithLatitude:obj2.lat longitude:obj2.lon];
                    CLLocationDistance d1 = [self.location distanceFromLocation:first];
                    CLLocationDistance d2 = [self.location distanceFromLocation:second];
                    if (d1 < d2) {
                        return NSOrderedAscending;
                    }
                    if (d1 > d2) {
                        return NSOrderedDescending;
                    }
                    return NSOrderedSame;
                }];
                
                [self.tableView reloadData];
            }
                break;
            case INTULocationStatusTimedOut: {
                [self showFUIAlertErrorWithMessage:@"Time out"];
            }
                
                break;
            case INTULocationStatusError: {
                [self showFUIAlertErrorWithMessage:@"Failed to Get Your Location"];
            }
                break;
            case INTULocationStatusServicesDenied: {
                [self showFUIAlertErrorWithMessage:@"Location services denied"];
            }
                break;
            case INTULocationStatusServicesDisabled: {
                [self showFUIAlertErrorWithMessage:@"Location services disabled"];
            }
                break;
            case INTULocationStatusServicesNotDetermined: {
                [self showFUIAlertErrorWithMessage:@"Location services not determined"];
            }
                break;
            case INTULocationStatusServicesRestricted: {
                [self showFUIAlertErrorWithMessage:@"Location services restricted"];
            }
                break;
            default:
                break;
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [VENTouchLock setShouldUseTouchID:YES];
    if ([[VENTouchLock sharedInstance] isPasscodeSet] ) {
        if (![VENTouchLock shouldUseTouchID]) {
            VENTouchLockEnterPasscodeViewController *showPasscodeVC = [[VENTouchLockEnterPasscodeViewController alloc] init];
            [self presentViewController:[showPasscodeVC embeddedInNavigationController] animated:YES completion:nil];
        }
        
    }
    else {
        VENTouchLockCreatePasscodeViewController *createPasscodeVC = [[VENTouchLockCreatePasscodeViewController alloc] init];
        [self presentViewController:[createPasscodeVC embeddedInNavigationController] animated:YES completion:nil];
    }
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont boldFlatFontOfSize:18], NSForegroundColorAttributeName: [UIColor midnightBlueColor]};
    [self.navigationItem.rightBarButtonItem removeTitleShadow];
    [self.navigationItem.leftBarButtonItem removeTitleShadow];
    [self.navigationController.navigationBar setBarTintColor:[UIColor cloudsColor]];
    UIBarButtonItem *simulate = [[UIBarButtonItem alloc] initWithTitle:@"Simulate" style:UIBarButtonItemStylePlain target:self action:@selector(simulateDB)];
//    UIBarButtonItem *simulate = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStylePlain target:self action:@selector(simulateDB)];
    NSMutableArray *rights = [self.navigationItem.rightBarButtonItems mutableCopy];
    [rights addObject:simulate];
    self.navigationItem.rightBarButtonItems = rights;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource   = self;
    self.tableView.tableFooterView      = [UIView new];
    
    self.arrWorkspaces = [[[WorkSpaceManager sharedManager] selectAll] mutableCopy];
    
    // Initialize the refresh control.
    self.refreshControl                 = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0];
    self.refreshControl.tintColor       = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(getLatestData)
                  forControlEvents:UIControlEventValueChanged];

    
    
    self.clManager                 = [[CLLocationManager alloc] init];
    geocoder                       = [[CLGeocoder alloc] init];
    self.clManager.delegate        = self;
    self.clManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.clManager requestWhenInUseAuthorization];
}

-(void) showFUIAlertErrorWithMessage:(NSString*) message {
    FUIAlertView *alertView                     = [[FUIAlertView alloc] initWithTitle:@"Error"
                                                                              message:message
                                                                             delegate:nil cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
    alertView.titleLabel.textColor              = [UIColor cloudsColor];
    alertView.titleLabel.font                   = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor            = [UIColor cloudsColor];
    alertView.messageLabel.font                 = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor    = [UIColor midnightBlueColor];
    alertView.defaultButtonColor                = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor          = [UIColor asbestosColor];
    alertView.defaultButtonFont                 = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor           = [UIColor asbestosColor];
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) getLatestData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.arrWorkspaces = [[[WorkSpaceManager sharedManager] selectAll] mutableCopy];
        [self reloadLocation];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
            
        });
    });
}

//#pragma mark - Search Controller delegate
//- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
//    NSString *searchText = searchController.searchBar.text;
//    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
//    self.searchResults = [self.arrWorkspaces filteredArrayUsingPredicate:resultPredicate];
//}

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
-(void)didUpdatedWS:(WorkSpaceModel*) ws {
    int index = -1;
    WorkSpaceModel *tmp;
    for (int i = 0; i < [self.arrWorkspaces count]; i++) {
        tmp = [self.arrWorkspaces objectAtIndex:i];
        if (tmp.id == ws.id) {
            index = i;
            [self.arrWorkspaces replaceObjectAtIndex:index withObject:ws];
            break;
        }
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
}

#pragma mark - Prepare segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toMapView"]) {
        MapsViewController *mapView = (MapsViewController*)[[segue destinationViewController] topViewController];
        
        mapView.workSpaces = self.arrWorkspaces;
    } else if ([segue.identifier isEqualToString:@"createWS"]) {
        WSCreateViewController *wsCreate = (WSCreateViewController*)[segue destinationViewController];
        wsCreate.workSpaces              = self.arrWorkspaces;
        wsCreate.delegate                = self;
        wsCreate.isCreateNew             = YES;
    }
}

#pragma mark - Bar button item

- (void)barButtonClicked {

}

#pragma mark - Swipe Cell

-(BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

-(void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    WorkSpaceModel *ws = (WorkSpaceModel*)self.arrWorkspaces[indexPath.row];
    if (index == 1) {
        
        NSString *name = ws.name;
        
        [self.arrWorkspaces removeObjectAtIndex:indexPath.row];

        
        //delete from sql
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            if ([[WorkSpaceManager sharedManager] deleteOneWithName:name]) {
                NSError *error;
                [[NSFileManager defaultManager] removeItemAtPath:[[Utility getImagesPath] stringByAppendingPathComponent:ws.image_path] error:&error];
                [[NSFileManager defaultManager] removeItemAtPath:[[Utility getImagesPath] stringByAppendingPathComponent:ws.thumb_path] error:&error];
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //delete from table
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView reloadData];
            });
        });

    } else if (index == 0) {
        //[self performSegueWithIdentifier:@"editWS" sender:self];
        WorkSpaceModel *ws           = [self.arrWorkspaces objectAtIndex:indexPath.row];
        WSPopupViewController *popup = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"popup"];
        popup.ws                     = ws;
        popup.view.frame             = CGRectMake(0, 0, 320, 420);
        [cell hideUtilityButtonsAnimated:NO];
        [self presentPopUpViewController:popup];
        
//        [self presentViewController:viewCtrl animated:YES completion:^{
//            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
//        }];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    FUIAlertView *alertView                     = [[FUIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"Failed to Get Your Location"
                                                         delegate:nil cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    alertView.titleLabel.textColor              = [UIColor cloudsColor];
    alertView.titleLabel.font                   = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor            = [UIColor cloudsColor];
    alertView.messageLabel.font                 = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor    = [UIColor midnightBlueColor];
    alertView.defaultButtonColor                = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor          = [UIColor asbestosColor];
    alertView.defaultButtonFont                 = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor           = [UIColor asbestosColor];
    [alertView show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
//    NSLog(@"didUpdateToLocation: %@", newLocation);
//    CLLocation *currentLocation = newLocation;
//    NSLog(@"%f", [currentLocation horizontalAccuracy]);
    if ([newLocation horizontalAccuracy] < 100) {
        self.location = newLocation;
        [self.arrWorkspaces sortUsingComparator:^NSComparisonResult(WorkSpaceModel *obj1, WorkSpaceModel *obj2) {
            CLLocation *first     = [[CLLocation alloc] initWithLatitude:obj1.lat longitude:obj1.lon];
            CLLocation *second    = [[CLLocation alloc] initWithLatitude:obj2.lat longitude:obj2.lon];
            CLLocationDistance d1 = [self.location distanceFromLocation:first];
            CLLocationDistance d2 = [self.location distanceFromLocation:second];
            if (d1 < d2) {
                return NSOrderedAscending;
            }
            if (d1 > d2) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];

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
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"Edit"];
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
    UIImage *thumb = [UIImage imageWithContentsOfFile:[[Utility getImagesPath] stringByAppendingPathComponent:model.thumb_path]];
    if (model.thumb_path)
        cell.thumbView.image = thumb;
    else
        cell.thumbView.image = [UIImage imageNamed:@"Sad"];
    cell.nameLb.text = model.name;
//    if (!self.location) {
//        [cell.dstLabel setHidden:YES];
//    } else {
        CLLocation *wsLocation = [[CLLocation alloc] initWithLatitude:model.lat longitude:model.lon];
        double dst = [wsLocation distanceFromLocation:self.location];
        cell.dstLabel.text = [DistanceHelper stringWithDistance:dst];
    
    //cell.addrLb.text = model.address;
    
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WorkSpaceModel *ws           = [self.arrWorkspaces objectAtIndex:indexPath.row];
    WSCreateViewController *viewCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WSCreate"];
    viewCtrl.workSpaces              = self.arrWorkspaces;
    viewCtrl.delegate                = self;
    viewCtrl.isCreateNew             = NO;
    viewCtrl.ws                      = ws;
    [self.navigationController pushViewController:viewCtrl animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
