//
//  WSCreateViewController.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/23/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "WSCreateViewController.h"
#import "UIImage+FixOrientation.h"
#import "EXPhotoViewer.h"

@interface WSCreateViewController () <MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, CLLocationManagerDelegate, UITextFieldDelegate>

@property (weak, nonatomic  ) IBOutlet MKMapView         *mapView;
@property (weak, nonatomic  ) IBOutlet FUIButton         *photoButton;
@property (weak, nonatomic  ) IBOutlet FUITextField      *nameTF;
@property (weak, nonatomic  ) IBOutlet FUITextField      *username;
@property (weak, nonatomic  ) IBOutlet FUITextField      *password;
@property (weak, nonatomic  ) IBOutlet FUITextField      *ipAddr;
@property (weak, nonatomic  ) IBOutlet UIImageView       *photoIV;
@property (weak, nonatomic  ) IBOutlet UIBarButtonItem   *saveButton;
//@property (nonatomic, strong) MKUserLocation    *location;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (weak, nonatomic) IBOutlet FUIButton *useLocationButton;

@end

@implementation WSCreateViewController

BOOL hasPhoto = NO;
UIImage *photo;

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.photoIV.image = image;
//    [self.photoButton setBackgroundImage:image forState:UIControlStateNormal];
//    [self.photoButton setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
//    self.photoButton.titleLabel.text = @"";
    
    hasPhoto = YES;
    photo = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    if (buttonIndex == 0) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else if (buttonIndex == 1) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.showsCameraControls = YES;
    } else {
        return;
    }
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)didPhotoClicked:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Library", @"Camera", nil];
    [actionSheet showInView:self.view];
}
- (IBAction)useCurrentLocationClicked:(id)sender {
    if (!self.location) {
        [self showFUIAlertErrorWithMessage:@"Failed to get Location"];
    } else {
        self.ws.lon = self.location.coordinate.longitude;
        self.ws.lat = self.location.coordinate.latitude;
    }
}

- (void)fillFieldsWS:(WorkSpaceModel *)ws {
    ws.name                   = self.nameTF.text;
    ws.username               = self.username.text;
    ws.password               = self.password.text;
    ws.ipaddr                 = self.ipAddr.text;
    ws.lon                    = self.ws.lon;
    ws.lat                    = self.ws.lat;
    if (photo) {
        NSString *documentsPath = [Utility getImagesPath];
        NSString *uuid            = [[NSUUID UUID] UUIDString];
        NSString *imageName;
        NSString *scaledImageName;
        if (self.isCreateNew || !ws.image_path.length || !ws.thumb_path.length) {
            imageName       = uuid;
            scaledImageName = [uuid stringByAppendingString:@"_scaled"];
            ws.image_path = imageName;
            ws.thumb_path = scaledImageName;
        } else {
            imageName = ws.image_path;
            scaledImageName = ws.thumb_path;
        }
        NSString *imagePath       = [documentsPath stringByAppendingPathComponent:imageName];
        NSString *scaledImagePath = [documentsPath stringByAppendingPathComponent:scaledImageName];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *scaledPhoto      = [ImageHelper imageWithImage:photo scaledToSize:CGSizeMake(100, 100)];
            [ImageHelper saveImage:photo to:imagePath];
            [ImageHelper saveImage:scaledPhoto to:scaledImagePath];
            
        });
    }
}

-(void) updateWS {
    // do not need to update location :)
    WorkSpaceModel *ws        = [[WorkSpaceModel alloc] init];
    ws.id                     = self.ws.id;
    [self fillFieldsWS:ws];
    [[WorkSpaceManager sharedManager] updateOne:ws];
    if (self.delegate) {
        [self.delegate didUpdatedWS:ws];
    }
    [self.navigationController popViewControllerAnimated:YES];
}



-(void) createNewWS {
    WorkSpaceModel *ws        = [[WorkSpaceModel alloc] init];
    [self fillFieldsWS:ws];
    
    
    [[WorkSpaceManager sharedManager] addOne:ws];
    if (self.delegate) {
        [self.delegate didCreatedWS:ws];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didSave:(id)sender {
    if (self.isCreateNew) {
        [self createNewWS];
    } else {
        [self updateWS];
    }
}
- (IBAction)didCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
//    if (!self.location) {
//        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
//        self.location             = userLocation;
//        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:NO];
//        
//    }
//}

-(void)flatTextField:(FUITextField*) myTextField {
    myTextField.font            = [UIFont flatFontOfSize:16];
    myTextField.backgroundColor = [UIColor clearColor];
    myTextField.edgeInsets      = UIEdgeInsetsMake(4.0f, 15.0f, 4.0f, 15.0f);
    myTextField.textFieldColor  = [UIColor whiteColor];
    myTextField.borderColor     = [UIColor turquoiseColor];
    myTextField.borderWidth     = 2.0f;
    myTextField.cornerRadius    = 3.0f;
}

-(void) tapDetected:(UITapGestureRecognizer *) gr {
    if (gr.state == UIGestureRecognizerStateEnded) {
        if (self.photoIV.image) {
            [EXPhotoViewer showImageFrom:self.photoIV];
        } else {
            [self didPhotoClicked:nil];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isCreateNew)
        [self.saveButton setEnabled:NO];
    self.mapView.delegate  = self;
    self.nameTF.delegate   = self;
    self.username.delegate = self;
    self.password.delegate = self;
    self.ipAddr.delegate   = self;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    singleTap.numberOfTapsRequired = 1;
    [self.photoIV setUserInteractionEnabled:YES];
    [self.photoIV addGestureRecognizer:singleTap];
    
    [self flatTextField:self.nameTF];
    [self flatTextField:self.username];
    [self flatTextField:self.password];
    [self flatTextField:self.ipAddr];
    
    if (!self.isCreateNew) {
        self.nameTF.text   = self.ws.name;
        self.username.text = self.ws.username;
        self.password.text = self.ws.password;
        self.ipAddr.text   = self.ws.ipaddr;
        UIImage *image     = [UIImage imageNamed:[[Utility getImagesPath] stringByAppendingPathComponent:self.ws.image_path]];
        self.photoIV.image = image;
        hasPhoto = YES;
        photo = image;
    }
    self.photoButton.buttonColor     = [UIColor turquoiseColor];
    self.photoButton.shadowColor     = [UIColor greenSeaColor];
    self.photoButton.shadowHeight    = 3.0f;
    self.photoButton.cornerRadius    = 6.0f;
    self.photoButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.photoButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.photoButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    self.useLocationButton.buttonColor     = [UIColor turquoiseColor];
    self.useLocationButton.shadowColor     = [UIColor greenSeaColor];
    self.useLocationButton.shadowHeight    = 3.0f;
    self.useLocationButton.cornerRadius    = 6.0f;
    self.useLocationButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.useLocationButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.useLocationButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock timeout:20 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        switch (status) {
            case INTULocationStatusSuccess: {
                self.location = currentLocation;
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
    
    // Do any additional setup after loading the view.
    //    self.locationManager = [[CLLocationManager alloc] init];
    //    [self.locationManager setDelegate:self];
    //    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    //    [self.locationManager requestAlwaysAuthorization];
    //    [self.locationManager startUpdatingLocation];
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

#pragma mark - Text field delegate

- (NSUInteger) textLengthAfterTrimming:(NSString*) string {
    return [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
}

- (BOOL) enableSaveButton {
    return ([self textLengthAfterTrimming:self.nameTF.text]&&
            [self textLengthAfterTrimming:self.username.text]&&
            [self textLengthAfterTrimming:self.password.text]&&
            [self textLengthAfterTrimming:self.ipAddr.text]);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self enableSaveButton]) {
        [self.saveButton setEnabled:YES];
    } else {
        [self.saveButton setEnabled:NO];
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
