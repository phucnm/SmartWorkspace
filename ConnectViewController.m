//
//  ConnectViewController.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/19/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "ConnectViewController.h"
#import "PickWSTableViewController.h"
#import "ActionViewController.h"

@interface ConnectViewController () <NSStreamDelegate, CLLocationManagerDelegate, PickWSDelegate, CNPGridMenuDelegate, QRCodeReaderDelegate, GCDAsyncSocketDelegate>
//@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic  ) IBOutlet UIButton          *connectButton;
@property (weak, nonatomic  ) IBOutlet UILabel           *statusLabel;
@property (weak, nonatomic  ) IBOutlet FUIButton         *startButton;
@property (weak, nonatomic  ) IBOutlet UIButton          *sendHeaderButton;
@property (nonatomic, retain) NSInputStream     *inputStream;
@property (nonatomic, retain) NSOutputStream    *outputStream;
@property (weak, nonatomic  ) IBOutlet UITextField       *ipTF;
@property (weak, nonatomic  ) IBOutlet UITextField       *portTF;
@property (strong, nonatomic) CLLocationManager *clManager;
@property (strong, nonatomic) NSArray           *workspaces;
@property (weak, nonatomic  ) IBOutlet UILabel           *wsName;
@property (weak, nonatomic  ) IBOutlet UIImageView       *wsImage;
@property (weak, nonatomic) IBOutlet FUIButton *scanQRButton;
@property (weak, nonatomic  ) IBOutlet FUIButton         *searchButton;
@property (weak, nonatomic  ) IBOutlet FUIButton         *actionButton;
@property (strong, nonatomic) NSMutableArray    *connectableWs;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) QRCodeReaderViewController *reader;
@property (nonatomic) BOOL isConnectedToKiosk;
@property (nonatomic, strong) NSString *kioskIp;
@property (nonatomic, strong) NSString *kioskPort;
@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
@property (nonatomic, strong) NSNumber *idNumber;
@property (nonatomic) BOOL isSendDone;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation ConnectViewController

#pragma mark - Scan QR code

- (IBAction)scanQRButtonClicked:(id)sender {
    NSArray *types = @[AVMetadataObjectTypeQRCode];
    self.reader        = [QRCodeReaderViewController readerWithMetadataObjectTypes:types];
    
    // Set the presentation style
    self.reader.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // Using delegate methods
    self.reader.delegate = self;
    
    [self presentViewController:self.reader animated:YES completion:nil];
}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result {
    NSLog(@"%@", result);
    [self.reader dismissViewControllerAnimated:YES completion:^{
        NSLog(@"dismiss");
        [self connectToKiosk:result];
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader {
    NSLog(@"Cancel");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) connectToKiosk:(NSString*) result {
    self.connectWs.ipaddr = result;
    NSString *host = [NSString stringWithFormat:@"http://%@:3000/kiosk/connect",result];
    [self.manager GET:host parameters:@{@"id":self.idNumber} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isConnectedToKiosk = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

#pragma mark - Actions
- (IBAction)showActions:(id)sender {
    NSArray *services = [[ServiceManager sharedManager] selectAll];
    
    NSMutableArray *items = [NSMutableArray array];
    
    for (ServiceModel* service in services) {
        if (service.type > 2 && [service.username length] && [service.password length]) {
            CNPGridMenuItem *item = [[CNPGridMenuItem alloc] init];
            item.icon = [UIImage imageNamed:[NSString stringWithFormat:@"%@2", service.icon_path]];
            item.title = service.name;
            item.isTapped = NO;
            item.tag = service;
            [items addObject:item];
        }
    }
    
//    CNPGridMenuItem *news = [[CNPGridMenuItem alloc] init];
//    news.icon = [UIImage imageNamed:@"news"];
//    news.title = @"What's News";
//    [items addObject:news];
    
    CNPGridMenuItem *logout = [[CNPGridMenuItem alloc] init];
    logout.icon = [UIImage imageNamed:@"windows2"];
    logout.title = @"Logout";
    logout.isTapped = NO;
    [items addObject:logout];
    
    if (self.isConnectedToKiosk) {
        CNPGridMenuItem *kiosk = [[CNPGridMenuItem alloc] init];
        kiosk.icon = [UIImage imageNamed:@"windows2"];
        kiosk.title = @"Disconnect Kiosk";
        kiosk.isTapped = NO;
        [items addObject:kiosk];
    }
    
    CNPGridMenuItem *back = [[CNPGridMenuItem alloc] init];
    back.icon = [UIImage imageNamed:@"return"];
    back.title = @"Back";
    back.isTapped = NO;
    [items addObject:back];
    
    
    CNPGridMenu *gridMenu = [[CNPGridMenu alloc] initWithMenuItems:items];
    gridMenu.delegate = self;
    [self presentGridMenu:gridMenu animated:YES completion:^{
        NSLog(@"Grid Menu Presented");
    }];

}

-(void)gridMenu:(CNPGridMenu *)menu didTapOnItem:(CNPGridMenuItem *)item {
    if ([item.title isEqualToString:@"Logout"]) {
        NSString *host = [NSString stringWithFormat:@"http://%@%@",self.connectWs.ipaddr,@":3000/logout"];
        [self.manager GET:host parameters:@{@"id":self.idNumber} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self dismissGridMenuAnimated:YES completion:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self showFUIAlertErrorWithMessage:[NSString stringWithFormat:@"%@", error.localizedDescription]];
        }];
    } else if ([item.title isEqualToString:@"Back"]) {
        [self dismissGridMenuAnimated:YES completion:^{
            
        }];
    } else if ([item.title isEqualToString:@"What's News"]) {
        [self handleWhatNews];
    } else if ([item.title isEqual:@"Disconnect Kiosk"]) {
        [self handleDisconnectKiosk];
        [self dismissGridMenuAnimated:YES completion:nil];
    } else {
        [self handleGridMenuItem:item];
    }
}
#pragma mark - handle actions
-(void) handleDisconnectKiosk {
    NSString *host = [NSString stringWithFormat:@"http://%@:3000/kiosk/disconnect",self.connectWs.ipaddr];
    [self.manager GET:host parameters:@{@"id":self.idNumber} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.isConnectedToKiosk = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

-(void) handleWhatNews {
//    NSMutableDictionary *tokens = [NSMutableDictionary dictionary];
//    NSString *facebook_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"Facebook_AccessToken"];
//    if (facebook_token)
//        [tokens setObject:facebook_token forKey:@"facebook_token"];
//    NSString *dropbox_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"Dropbox_AccessToken"];
//    NSString *dropbox_token_secret = [[NSUserDefaults standardUserDefaults] objectForKey:@"Dropbox_AccessTokenSecret"];
//    if (dropbox_token && dropbox_token_secret) {
//        [tokens setObject:dropbox_token forKey:@"dropbox_token"];
//        [tokens setObject:dropbox_token_secret forKey:@"dropbox_token_secret"];
//    }
//    NSString *flickr_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"Flickr_AccessToken"];
//    if (flickr_token)
//        [tokens setObject:flickr_token forKey:@"flickr_token"];
    
    //NSLog(@"%@", tokens);
    
    NSString *host = [NSString stringWithFormat:@"http://%@%@",self.connectWs.ipaddr,@":3000/news/login"];

    [self.manager POST:host parameters:@{@"id":self.idNumber} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showFUIAlertErrorWithMessage:error.localizedDescription];
    }];
}

-(void) handleYahoo:(CNPGridMenuItem*)item {
    ServiceModel *service = item.tag;
    
    if (item.isTapped) { //is logged in
        NSString *host = [NSString stringWithFormat:@"http://%@%@",self.connectWs.ipaddr,@":3000/yahoo/logout"];
        [self.manager GET:host parameters:@{@"id":self.idNumber} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            item.isTapped = !item.isTapped;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self showFUIAlertErrorWithMessage:error.localizedDescription];
        }];

    } else {
        NSString *host = [NSString stringWithFormat:@"http://%@%@",self.connectWs.ipaddr,@":3000/yahoo/login"];
        NSDictionary *params = [NSDictionary dictionaryWithObjects:@[service.username, service.password, self.idNumber] forKeys:@[@"username", @"password", @"id"]];
        [self.manager POST:host parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            item.isTapped = !item.isTapped;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self showFUIAlertErrorWithMessage:error.localizedDescription];
        }];
    }
}
-(void) handleSkype:(CNPGridMenuItem*)item {
    ServiceModel *service = item.tag;
    
    if (item.isTapped) { //is logged in
        NSString *host = [NSString stringWithFormat:@"http://%@%@",self.connectWs.ipaddr,@":3000/skype/logout"];
        [self.manager GET:host parameters:@{@"id":self.idNumber} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            item.isTapped = !item.isTapped;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self showFUIAlertErrorWithMessage:error.localizedDescription];
        }];
        
    } else {
        NSString *host = [NSString stringWithFormat:@"http://%@%@",self.connectWs.ipaddr,@":3000/skype/login"];
        NSDictionary *params = [NSDictionary dictionaryWithObjects:@[service.username, service.password, self.idNumber] forKeys:@[@"username", @"password", @"id"]];
        [self.manager POST:host parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            item.isTapped = !item.isTapped;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self showFUIAlertErrorWithMessage:error.localizedDescription];
        }];
    }

}
-(void) handleDropbox:(CNPGridMenuItem*)item {
    ServiceModel *service = item.tag;
    NSString *host = [NSString stringWithFormat:@"http://%@%@",self.connectWs.ipaddr,@":3000/dropbox"];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[service.username, service.password, self.idNumber] forKeys:@[@"username", @"password", @"id"]];
    [self.manager POST:host parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        item.isTapped = !item.isTapped;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showFUIAlertErrorWithMessage:error.localizedDescription];
    }];
}
-(void) handleGmail:(CNPGridMenuItem*)item {
    ServiceModel *service = item.tag;
    NSString *host = [NSString stringWithFormat:@"http://%@%@",self.connectWs.ipaddr,@":3000/gmail"];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[service.username, service.password, self.idNumber] forKeys:@[@"username", @"password", @"id"]];
    [self.manager POST:host parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        item.isTapped = !item.isTapped;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showFUIAlertErrorWithMessage:error.localizedDescription];
    }];
}

-(void) handleFacebook:(CNPGridMenuItem*)item {
    ServiceModel *service = item.tag;
    NSString *host = [NSString stringWithFormat:@"http://%@%@",self.connectWs.ipaddr,@":3000/fb"];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[service.username, service.password, self.idNumber] forKeys:@[@"username", @"password", @"id"]];
    [self.manager POST:host parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        item.isTapped = !item.isTapped;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showFUIAlertErrorWithMessage:error.localizedDescription];
    }];

}
- (void)handleGridMenuItem:(CNPGridMenuItem*)item {
    ServiceModel *service = item.tag;
    
    switch (service.type) {
        case YAHOO_WIN: {
            [self handleYahoo:item];
        }
            break;
        case SKYPE_WIN: {
            [self handleSkype:item];
        }
            break;
        case FACEBOOK_WEB: {
            [self handleFacebook:item];
        }
            break;
        case DROPBOX_WEB: {
            [self handleDropbox:item];
        }
            break;
        case GMAIL_WEB: {
            [self handleGmail:item];
        }
            break;
        default:
            break;
    }
}

#pragma Start connecting
//Connect to workspace butotn
- (IBAction)startClicked:(id)sender {
    [SVProgressHUD showWithStatus:@"Connecting"];
    //Time out 3.0 sec
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(timedOut) userInfo:nil repeats:NO];
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        [self initNetworkCommunication];
        [self sendCredentials];
        self.isSendDone = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.actionButton setEnabled:YES];
        });
    });
}


#pragma mark - Search for Workspaces

- (IBAction)searchClicked:(id)sender {
//    self.clManager.delegate = self;
//    [self.clManager startUpdatingLocation];
    [self.startButton setEnabled:NO];
    [self.clManager startUpdatingLocation];
    //[self.actionButton setEnabled:NO];
//    [self startINTULocation];
//    [SVProgressHUD showWithStatus:@"Searching for workspaces"];
}

- (void) startINTULocation {
    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock timeout:20 block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        [SVProgressHUD dismiss];
        switch (status) {
            case INTULocationStatusSuccess: {
                self.connectableWs = [NSMutableArray array];
                int radiusAround = 100;
                for (int i = 0; i < [self.workspaces count]; i++) {
                    WorkSpaceModel *tmpWs = [self.workspaces objectAtIndex:i];
                    CLLocation *tmpLocation = [[CLLocation alloc] initWithLatitude:tmpWs.lat longitude:tmpWs.lon];
                    double dst = [currentLocation distanceFromLocation:tmpLocation];
                    if (dst <= radiusAround) {
                        [self.connectableWs addObject:tmpWs];
                    }
                }
                if ([self.connectableWs count] == 0) {
                    FUIAlertView *alertView                     = [[FUIAlertView alloc] initWithTitle:@"Sorry"
                                                                                              message:@"No workspaces are near here"
                                                                                             delegate:nil cancelButtonTitle:@"I know"
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
                } else if ([self.connectableWs count] == 1) {
                    self.connectWs = [self.connectableWs firstObject];
                    [self chosenAWS];
                } else {
                    PickWSTableViewController *pickViewCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PickWS"];
                    pickViewCtrl.workspaces = self.connectableWs;
                    pickViewCtrl.delegate = self;
//                    [self.navigationController pushViewController:pickViewCtrl animated:YES];
                    [self presentViewController:pickViewCtrl animated:YES completion:nil];
                }
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

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    [SVProgressHUD dismiss];
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

//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    CLLocation *location = [locations lastObject];
//    if ([location horizontalAccuracy] > 75) {
//        return;
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [SVProgressHUD dismiss];
//    });
//    
//    self.connectableWs = [NSMutableArray array];
//    int radiusAround = 100;
//    for (int i = 0; i < [self.workspaces count]; i++) {
//        WorkSpaceModel *tmpWs = [self.workspaces objectAtIndex:i];
//        CLLocation *tmpLocation = [[CLLocation alloc] initWithLatitude:tmpWs.lat longitude:tmpWs.lon];
//        double dst = [location distanceFromLocation:tmpLocation];
//        if (dst <= radiusAround) {
//            [self.connectableWs addObject:tmpWs];
//
//        }
//    }
//    [self.clManager stopUpdatingLocation];
//    self.clManager.delegate = nil;
//    if ([self.connectableWs count] == 0) {
//        //[SVProgressHUD showErrorWithStatus:@"No workspaces are near here"];
//        FUIAlertView *alertView                     = [[FUIAlertView alloc] initWithTitle:@"Sorry"
//                                                              message:@"No workspaces are near here"
//                                                             delegate:nil cancelButtonTitle:@"I know"
//                                                    otherButtonTitles:nil];
//        alertView.titleLabel.textColor              = [UIColor cloudsColor];
//        alertView.titleLabel.font                   = [UIFont boldFlatFontOfSize:16];
//        alertView.messageLabel.textColor            = [UIColor cloudsColor];
//        alertView.messageLabel.font                 = [UIFont flatFontOfSize:14];
//        alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
//        alertView.alertContainer.backgroundColor    = [UIColor midnightBlueColor];
//        alertView.defaultButtonColor                = [UIColor cloudsColor];
//        alertView.defaultButtonShadowColor          = [UIColor asbestosColor];
//        alertView.defaultButtonFont                 = [UIFont boldFlatFontOfSize:16];
//        alertView.defaultButtonTitleColor           = [UIColor asbestosColor];
//        [alertView show];
//    } else if ([self.connectableWs count] == 1) {
//        //[self.connectButton setEnabled:YES];
//        //[self.connectButton sendActionsForControlEvents:UIControlEventTouchUpInside];
//        self.connectWs = [self.connectableWs firstObject];
//        [self chosenAWS];
//    } else {
//        PickWSTableViewController *pickViewCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PickWS"];
//        pickViewCtrl.workspaces = self.connectableWs;
//        pickViewCtrl.delegate = self;
//        [self presentViewController:pickViewCtrl animated:YES completion:nil];
//    }
//}

-(void) chosenAWS {
    self.wsName.text = self.connectWs.name;
    [self.wsName setFont:[UIFont flatFontOfSize:16]];
    UIImage *image = [UIImage imageNamed:[[Utility getImagesPath] stringByAppendingPathComponent:self.connectWs.image_path]];
//    UIImage *image = [UIImage imag
  //                    self.connectWs.image_path];
    if (image) {
        self.wsImage.image = image;
    } else {
        self.wsImage.image = [UIImage imageNamed:@"Sad"];
    }
    //self.startButton.titleLabel.text = @"Connect";
    [self.startButton setEnabled:YES];
}

-(void)didSelectedWS:(int)index {
    self.connectWs = [self.connectableWs objectAtIndex:index];
    //[self.connectButton setEnabled:YES];
    [self chosenAWS];
}

#pragma mark - Socket - Login Windows
- (void) initNetworkCommunication {
    //[self.indicator startAnimating];
    //NSString *host = self.connectWs.ipaddr;
    NSString *host = self.connectWs.ipaddr;
    //PORT
    int port = 65432;
    //    int port       = [self.portTF.text intValue];
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)CFBridgingRetain(host), port, &readStream, &writeStream);
    //NSLog(@"init socket");
    //[self.status.text stringByAppendingFormat:@"Init socket"];
    self.inputStream  = CFBridgingRelease((readStream));
    self.outputStream = CFBridgingRelease((writeStream));
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    [self.outputStream open];
    
    //[self.status.text stringByAppendingFormat:@"\nConnected to host %@:%d", host, port];
}

- (void) timedOut {
    if (!self.isSendDone) {
        [SVProgressHUD dismiss];
        [self.actionButton setEnabled:YES];
        [self showFUIAlertErrorWithMessage:@"There was an internet problem. Try again"];
    }
    [self.timer invalidate];
    self.timer = nil;
}

- (IBAction)connectClicked:(id)sender {
    [SVProgressHUD showWithStatus:@"Connecting"];
    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(timedOut) userInfo:nil repeats:NO];
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        [self initNetworkCommunication];
        [self sendCredentials];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    });
    
}

-(void) sendCredentials {
    //to test encrypt function only
    NSString *res = [[BasicHelper sharedHelper] encryptCPP:@"phuc"];
    NSLog(@"%@", res);
    NSString *rev = [[BasicHelper sharedHelper] encryptCPP:res];
    NSLog(@"%@", rev);
    
    //what is id mobile ?
    //circumstance: a mobile device has to demo that server only accept socket login from
    //which id is registered before
    //(id.txt in C:/SmartSystem/)
    NSString *idMobile = [AppDelegate sharedDelegate].simulateMode;
    [self sendMessage:idMobile];
    [self receiveMessage];
    [self sendMessage:self.connectWs.username];
    [self receiveMessage];
    [self sendMessage:self.connectWs.password];
    [self receiveMessage];
    [self sendMessage:self.connectWs.computer_name];
}
- (IBAction)sendHeader:(id)sender {
    NSLog(@"sending header");
    //NSString *header = @"NMPNMPNMP";
    NSString *userName   = @"phuc";
    NSString *password   = @"12345678";
    NSString *domainName = @"PN9999";

    [self sendMessage:userName];
    NSLog(@"sent username");
    [self receiveMessage];
    [self sendMessage:password];
    NSLog(@"sent pwd");
    [self receiveMessage];
    [self sendMessage:domainName];
    NSLog(@"sending credential");

}

-(void)receiveMessage {
    uint8_t buffer[1024];
    int len;
    len = (int)[self.inputStream read:buffer maxLength:sizeof(buffer)];
    NSString *receivedMessage = [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
    [self handleReceivedMessage:receivedMessage];

}

-(void) handleReceivedMessage:(NSString*) message {
    //NSString *decryptedMessage = (NSString*)[[BasicHelper sharedHelper] decrypt:message];
//    NSLog(@"%@", )
    //[self.status.text stringByAppendingFormat:@"\n%@", decryptedMessage];
    NSLog(@"%@", message);
}

-(void) sendMessage:(NSString*) message {
    //[self.outputStream open];
    NSString *encryptedMessage = (NSString*)[[BasicHelper sharedHelper] encryptCPP:message];
    NSData *data = [[NSData alloc] initWithData:[encryptedMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [self.outputStream write:[data bytes] maxLength:[data length]];
    //[self.outputStream close];
}

-(void) sendMessageNew:(NSString*) message {
    NSString *encryptedMessage = (NSString*)[[BasicHelper sharedHelper] encryptCPP:message];
    NSData *data = [[NSData alloc] initWithData:[encryptedMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [self.asyncSocket writeData:data withTimeout:-1 tag:0];
}

- (void) initNetworkNew {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    NSString *host = self.connectWs.ipaddr;
    uint16_t port = SOCKET_PORT;
    
    //NSLog(@"Connecting to \"%@\" on port %hu...", host, port);
    
    NSError *error = nil;
    if (![self.asyncSocket connectToHost:host onPort:port error:&error])
    {
        //NSLog(@"Error connecting: %@", error);
    }
}

#pragma mark - Async socket delegate

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"SOCKET - Connected to host %@ on port %hu", host, port);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"SOCKET - Did write data with tag %ld", tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"SOCKET - Did read data %@ with tag %ld", strData, tag);
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.workspaces = [[WorkSpaceManager sharedManager] selectAll];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //hard code
    //send id in every request to recognize what is the coming device
    //situation: when server first received a request from a device (with id)
    //after that, server does not respond to other device (based on current device id)
    //until the device is disconnected from server
    //TODO: refactor this
    self.idNumber = @1;
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    //Location manager
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.clManager = [[CLLocationManager alloc] init];
    [self.clManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.clManager setDelegate:self];
    
    //setup UI
    self.startButton.buttonColor  = [UIColor turquoiseColor];
    self.startButton.shadowColor  = [UIColor greenSeaColor];
    self.startButton.shadowHeight = 3.0f;
    self.startButton.cornerRadius = 6.0f;
    self.startButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.startButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    self.searchButton.buttonColor  = [UIColor amethystColor];
    self.searchButton.shadowColor  = [UIColor greenSeaColor];
    self.searchButton.shadowHeight = 3.0f;
    self.searchButton.cornerRadius = 6.0f;
    self.searchButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.searchButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.searchButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    self.scanQRButton.buttonColor  = [UIColor amethystColor];
    self.scanQRButton.shadowColor  = [UIColor greenSeaColor];
    self.scanQRButton.shadowHeight = 3.0f;
    self.scanQRButton.cornerRadius = 6.0f;
    self.scanQRButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.scanQRButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.scanQRButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    self.actionButton.buttonColor  = [UIColor belizeHoleColor];
    self.actionButton.shadowColor  = [UIColor greenSeaColor];
    self.actionButton.shadowHeight = 3.0f;
    self.actionButton.cornerRadius = 6.0f;
    self.actionButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    [self.actionButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
    
    
    //Search and auto choose a workspace after did load VC
    [self.startButton setEnabled:NO];
    //[self.actionButton setEnabled:NO];
    if (!self.isFromMapOrAR) {
        //[self startINTULocation];
        [self.clManager startUpdatingLocation];
//        [SVProgressHUD showWithStatus:@"Searching for workspaces"];
    } else {
        [self chosenAWS];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

/// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ActionViewController *action = [segue destinationViewController];
    action.ipaddr = self.connectWs.ipaddr;
}

#pragma mark - location
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currentLocation = [locations lastObject];
    [self.clManager stopUpdatingLocation];
    self.connectableWs = [NSMutableArray array];
    int radiusAround = 100;
    for (int i = 0; i < [self.workspaces count]; i++) {
        WorkSpaceModel *tmpWs = [self.workspaces objectAtIndex:i];
        CLLocation *tmpLocation = [[CLLocation alloc] initWithLatitude:tmpWs.lat longitude:tmpWs.lon];
        double dst = [currentLocation distanceFromLocation:tmpLocation];
        if (dst <= radiusAround) {
            [self.connectableWs addObject:tmpWs];
        }
    }
    if ([self.connectableWs count] == 0) {
        FUIAlertView *alertView                     = [[FUIAlertView alloc] initWithTitle:@"Sorry"
                                                                                  message:@"No workspaces are near here"
                                                                                 delegate:nil cancelButtonTitle:@"I know"
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
    } else if ([self.connectableWs count] == 1) {
        self.connectWs = [self.connectableWs firstObject];
        [self chosenAWS];
    } else {
        PickWSTableViewController *pickViewCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PickWS"];
        pickViewCtrl.workspaces = self.connectableWs;
        pickViewCtrl.delegate = self;
        //                    [self.navigationController pushViewController:pickViewCtrl animated:YES];
        [self presentViewController:pickViewCtrl animated:YES completion:nil];
    }
}


@end
