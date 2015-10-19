//
//  ViewController.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/16/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "FBViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FBViewController () <FBSDKLoginButtonDelegate>
@property (weak, nonatomic) IBOutlet UILabel *usernameTV;
@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *profilePictureView;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation FBViewController

NSString* fbName = @"Facebook";

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    NSLog(@"Log out fb!");
    self.usernameTV.text = @"Un linked";
    /* Set UserDefaults  */
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:fbName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_AccessToken", fbName]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    /* */
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"%@", [[FBSDKAccessToken currentAccessToken] tokenString]);
        
        /* Set UserDefaults  */
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:fbName];
        [[NSUserDefaults standardUserDefaults] setObject:[[FBSDKAccessToken currentAccessToken] tokenString] forKey:[NSString stringWithFormat:@"%@_AccessToken", fbName]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
         
    }
    
    if ([FBSDKProfile currentProfile]) {
        FBSDKProfile *profile = [FBSDKProfile currentProfile];
        self.profilePictureView.profileID = profile.userID;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    if ([FBSDKAccessToken currentAccessToken]) {
        if ([FBSDKProfile currentProfile]) {
            FBSDKProfile *profile = [FBSDKProfile currentProfile];
            self.usernameTV.text = profile.name;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.delegate = self;
    loginButton.publishPermissions = @[@"publish_actions"]; 
    loginButton.readPermissions = @[@"read_stream", @"public_profile", @"email"];
    float X = (self.view.frame.size.width - 100)/2;
    float Y_Co = self.view.frame.size.height - 42 - self.tabBarController.tabBar.frame.size.height;
    [loginButton setFrame:CGRectMake(X, Y_Co, 100, 40)];
    [self.view addSubview:loginButton];
    


//    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginViewFetchedUserInfo:) name:@"FBSDKAccessTokenDidChangeNotification" object:nil];
}

//-(void) loginViewFetchedUserInfo:(NSNotification*) ns {
//    if ([FBSDKAccessToken currentAccessToken]) {
//        NSLog(@"%@", [[FBSDKAccessToken currentAccessToken] tokenString]);
//    }
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
