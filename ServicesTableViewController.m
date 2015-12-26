//
//  ServicesTableViewController.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/18/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "ServicesTableViewController.h"
#import "ServiceTableViewCell.h"
#import "ServiceConnectHelper.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import "AddCredTableViewController.h"
#import "ServiceManager.h"
#import <SVProgressHUD.h>

@interface ServicesTableViewController () <FBSDKLoginButtonDelegate, OFFlickrAPIRequestDelegate, SWTableViewCellDelegate, FUIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *arrServices;
@property (nonatomic) FBSDKLoginButton *loginButton;
@property (strong, nonatomic) NSArray *sections;
@end

@implementation ServicesTableViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont boldFlatFontOfSize:18], NSForegroundColorAttributeName: [UIColor midnightBlueColor]};
    //[self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor whiteColor]];
    [self.navigationItem.rightBarButtonItem removeTitleShadow];
    [self.navigationItem.leftBarButtonItem removeTitleShadow];
    [self.navigationController.navigationBar setBarTintColor:[UIColor cloudsColor]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    self.arrServices = [NSArray arrayWithObjects:
//                        [[ServiceModel alloc] initWithType:FACEBOOK_OAUTH andName:@"Facebook" andIcon:@"facebook"],
//                        [[ServiceModel alloc] initWithType:DROPBOX_OAUTH andName:@"Dropbox" andIcon:@"dropbox"],
//                        [[ServiceModel alloc] initWithType:FLICKR_OAUTH andName:@"Flickr" andIcon:@"flickr"],
//                        [[ServiceModel alloc] initWithType:FACEBOOK_WEB andName:@"Facebook Web" andIcon:@"facebook"],
//                        nil];
//    self.arrServices = @[@"Facebook", , @"Flickr", @"flickr-dreamstale30",
//                         @"Dropbox", @"dropbox-dreamstale20"];
    
    self.arrServices = [[[ServiceManager sharedManager] selectAll] mutableCopy];
    self.sections = [NSArray arrayWithObjects:@"OAuth services", @"Yahoo! Messenger", @"Skype", @"Facebook Web", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FUIAlert delegate
-(void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView textFieldAtIndex:0].text length] == 0)
        return;
    ServiceModel *model = [[ServiceModel alloc] init];
    switch (buttonIndex) {
        case 1: {
            model.type = YAHOO_WIN;
            model.icon_path = @"yahoo";
        }
            
            break;
        case 2:{
            model.type = SKYPE_WIN;
            model.icon_path = @"skype";
        }
            break;
        case 3:{
            model.type = FACEBOOK_WEB;
            model.icon_path = @"facebook";
        }
            break;
        case 4: {
            model.type = GMAIL_WEB;
            model.icon_path = @"google";
        }
            break;
        case 5: {
            model.type = DROPBOX_WEB;
            model.icon_path = @"dropbox";
        }
            break;
        default:
            return;
    }
    model.name = [alertView textFieldAtIndex:0].text;
    [SVProgressHUD show];
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
            [self.arrServices addObject:model];
        [[ServiceManager sharedManager] addOne:model];
        dispatch_async(dispatch_get_main_queue(), ^{
            //delete from table
            [SVProgressHUD dismiss];
             [self.tableView insertSections:[NSIndexSet indexSetWithIndex:[self.tableView numberOfSections]] withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    });

   
}

#pragma mark - Add button
- (IBAction)addButtonClicked:(id)sender {
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Create new identity" message:@"Enter name" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Yahoo! Messenger", @"Skype", @"Facebook web", @"Gmail web", @"Dropbox web", nil];
    alertView.alertViewStyle = FUIAlertViewStylePlainTextInput;
    [@[[alertView textFieldAtIndex:0], [alertView textFieldAtIndex:1]] enumerateObjectsUsingBlock:^(FUITextField *textField, NSUInteger idx, BOOL *stop) {
        [textField setTextFieldColor:[UIColor cloudsColor]];
        [textField setBorderColor:[UIColor asbestosColor]];
        [textField setCornerRadius:4];
        [textField setFont:[UIFont flatFontOfSize:14]];
        [textField setTextColor:[UIColor midnightBlueColor]];
    }];
    [[alertView textFieldAtIndex:0] setPlaceholder:@"Name"];
    [alertView textFieldAtIndex:0].delegate = self;
    alertView.delegate = self;
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



//#pragma mark - Segue
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    ServiceTableViewCell *cell = (ServiceTableViewCell*)[self.arrServices objectAtIndex:[self.tableView indexPathForSelectedRow].section];
//    AddCredTableViewController *addCred = [segue destinationViewController];
//    if ([segue.identifier isEqualToString:@"AddCredential"]) {
//        switch (cell.type) {
//            case FACEBOOK_WEB:
//
//                break;
//                
//            default:
//                break;
//        }
//    }
//}

#pragma mark - Swipe table view cell

- (NSArray *)rightButtonsLogout
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.2f alpha:1.0]
                                                        title:@"Logout"];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
//                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

- (NSArray *)rightButtonsDelete
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//        [rightUtilityButtons sw_addUtilityButtonWithColor:
//         [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
//                                                    title:@"Reconnect"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

-(void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    ServiceModel *model = [self.arrServices objectAtIndex:indexPath.section];
    //Trigger Delete button for not OAUTH type
    if (model.type > 2) {
        [self.arrServices removeObjectAtIndex:indexPath.section];
        //delete from sql
        [SVProgressHUD show];
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            [[ServiceManager sharedManager] deleteOneWithId:model.id];
            dispatch_async(dispatch_get_main_queue(), ^{
                //delete from table
                [SVProgressHUD dismiss];
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
                //[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView reloadData];
            });
        });
    } else { //log out button
        switch (model.type) {
            case FACEBOOK_OAUTH:{
                self.loginButton                    = [[FBSDKLoginButton alloc] init];
                self.loginButton.delegate           = self;
                self.loginButton.publishPermissions = @[@"publish_actions"];
                self.loginButton.readPermissions    = @[@"read_stream", @"public_profile", @"email"];
                [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
                break;
            case DROPBOX_OAUTH: {
                [[DBSession sharedSession] unlinkAll];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:model.name];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            case FLICKR_OAUTH: {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:model.name];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
                break;
            default:
                break;
        }
        [cell hideUtilityButtonsAnimated:NO];
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.arrServices count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ServiceTableViewCell *cell = (ServiceTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ServiceTableViewCell"];
    
    ServiceModel *model = (ServiceModel*)[self.arrServices objectAtIndex:indexPath.section];
    
    cell.iconView.image = [UIImage imageNamed:model.icon_path];
    cell.name.text = model.name;
    cell.type = model.type;
    switch (model.type) {
        case FACEBOOK_OAUTH:
        case DROPBOX_OAUTH:
        case FLICKR_OAUTH: {
            //[cell setUserInteractionEnabled:NO];
            ServiceConnectHelper *helper = [[ServiceConnectHelper alloc] initWithService:cell.name.text];
            if ([helper isConnected]) {
                //cell.connectedGreen.image = [UIImage imageNamed:@"ok"];
                [cell.connectButton setHidden:YES];
                [cell.connectedGreen setHidden:NO];
                cell.rightUtilityButtons = [self rightButtonsLogout];
                cell.delegate = self;
            } else {
                [cell.connectedGreen setHidden:YES];
                [cell.connectButton setHidden:NO];
                cell.connectButton.buttonColor     = [UIColor turquoiseColor];
                cell.connectButton.shadowColor     = [UIColor greenSeaColor];
                cell.connectButton.shadowHeight    = 3.0f;
                cell.connectButton.cornerRadius    = 6.0f;
                cell.connectButton.titleLabel.font = [UIFont boldFlatFontOfSize:16];
                [cell.connectButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
                [cell.connectButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
                //NSString *name = cell.name.text;
                if (cell.type == FACEBOOK_OAUTH) {
                    [cell.connectButton addTarget:self action:@selector(connectFacebook) forControlEvents:UIControlEventTouchUpInside];
                } else if (cell.type == FLICKR_OAUTH) {
                    [cell.connectButton addTarget:self action:@selector(connectFlickr) forControlEvents:UIControlEventTouchUpInside];
                } else if (cell.type == DROPBOX_OAUTH) {
                    [cell.connectButton addTarget:self action:@selector(connectDropbox) forControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
            
            break;
        case YAHOO_WIN:
        case SKYPE_WIN:
        case FACEBOOK_WEB:
        case DROPBOX_WEB:
        case GMAIL_WEB: {
            [cell.connectedGreen setHidden:YES];
            [cell.connectButton setHidden:YES];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            cell.rightUtilityButtons = [self rightButtonsDelete];
            cell.delegate = self;
        }
            break;
        default:
            break;
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ServiceTableViewCell *cell = (ServiceTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    AddCredTableViewController *addCred = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AddCred"];
    
    //NSString *name = @"";
    //ServiceModel *service = [[ServiceModel alloc] init];
    switch (cell.type) {
        case FACEBOOK_OAUTH:
        case DROPBOX_OAUTH:
        case FLICKR_OAUTH: {
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            return;
        }
        case YAHOO_WIN:
        case SKYPE_WIN:
        case FACEBOOK_WEB:
        case DROPBOX_WEB:
        case GMAIL_WEB: {
            //name = @"FB_WEB";
            ServiceModel *service = [self.arrServices objectAtIndex:indexPath.section];
            addCred.service = service;
            [self.navigationController pushViewController:addCred animated:YES];
        }
            break;
        default:
            break;
    }
}


#pragma mark - Connect Facebook

- (void) connectFacebook {
    self.loginButton                    = [[FBSDKLoginButton alloc] init];
    self.loginButton.delegate           = self;
    self.loginButton.publishPermissions = @[@"publish_actions"];
    self.loginButton.readPermissions    = @[@"read_stream", @"public_profile", @"email"];
    [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];

}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
//    NSLog(@"Log out fb!");
//    self.usernameTV.text = @"Un linked";
    /* Set UserDefaults  */
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Facebook"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_AccessToken", @"Facebook"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    /* */
    [self.tableView reloadData];
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"%@", [[FBSDKAccessToken currentAccessToken] tokenString]);
        
        /* Set UserDefaults  */
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Facebook"];
        [[NSUserDefaults standardUserDefaults] setObject:[[FBSDKAccessToken currentAccessToken] tokenString] forKey:[NSString stringWithFormat:@"%@_AccessToken", @"Facebook"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
    }
    [self.tableView reloadData];
    
//    if ([FBSDKProfile currentProfile]) {
//        FBSDKProfile *profile = [FBSDKProfile currentProfile];
//        self.profilePictureView.profileID = profile.userID;
//    }
}

#pragma mark - Connect Flickr

NSString *kFetchRequestTokenStep  = @"kFetchRequestTokenStep";
NSString *kGetUserInfoStep        = @"kGetUserInfoStep";
NSString *kSetImagePropertiesStep = @"kSetImagePropertiesStep";
NSString *kUploadImageStep        = @"kUploadImageStep";

-(void) connectFlickr {
    // if there's already OAuthToken, we want to reauthorize
    if ([[AppDelegate sharedDelegate].flickrContext.OAuthToken length]) {
        [[AppDelegate sharedDelegate] setAndStoreFlickrAuthToken:nil secret:nil];
    }
    
//    NSLog(@"%@", @"AUthenticating");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flickrDidLogin:) name:@"FlickrLogin" object:nil];
    
    self.flickrRequest.sessionInfo = kFetchRequestTokenStep;
    [self.flickrRequest fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:SRCallbackURLBaseString]];
    

    
}

-(void) flickrDidLogin:(NSNotification*) ns {
    [self.tableView reloadData];
}

-(OFFlickrAPIRequest*) flickrRequest {
    if (!_flickrRequest) {
        _flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:[AppDelegate sharedDelegate].flickrContext];
        _flickrRequest.delegate = self;
        _flickrRequest.requestTimeoutInterval = 60.0;
    }
    
    return _flickrRequest;
}

-(void) flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret {
    // these two lines are important
    [AppDelegate sharedDelegate].flickrContext.OAuthToken = inRequestToken;
    [AppDelegate sharedDelegate].flickrContext.OAuthTokenSecret = inSecret;
    
    NSURL *authURL = [[AppDelegate sharedDelegate].flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    [[UIApplication sharedApplication] openURL:authURL];
}

#pragma mark - Connect Dropbox
-(void) connectDropbox {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxDidLogin:) name:@"DropboxLogin" object:nil];
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }

}

-(void) dropboxDidLogin:(NSNotification*) ns {
    [self.tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

@end
