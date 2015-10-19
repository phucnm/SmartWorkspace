//
//  FLViewController.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/19/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "FLViewController.h"
#import "AppDelegate.h"

//NSString *kFetchRequestTokenStep = @"kFetchRequestTokenStep";
//NSString *kGetUserInfoStep = @"kGetUserInfoStep";
//NSString *kSetImagePropertiesStep = @"kSetImagePropertiesStep";
//NSString *kUploadImageStep = @"kUploadImageStep";

@interface FLViewController () <OFFlickrAPIRequestDelegate>

@end

@implementation FLViewController

-(OFFlickrAPIRequest*) flickrRequest {
    if (!_flickrRequest) {
        _flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:[AppDelegate sharedDelegate].flickrContext];
        _flickrRequest.delegate = self;
        _flickrRequest.requestTimeoutInterval = 60.0;
    }
    
    return _flickrRequest;
}

-(void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret {
    // these two lines are important
    [AppDelegate sharedDelegate].flickrContext.OAuthToken = inRequestToken;
    [AppDelegate sharedDelegate].flickrContext.OAuthTokenSecret = inSecret;
    
    NSURL *authURL = [[AppDelegate sharedDelegate].flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    [[UIApplication sharedApplication] openURL:authURL];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)loginClicked:(id)sender {
    // if there's already OAuthToken, we want to reauthorize
    if ([[AppDelegate sharedDelegate].flickrContext.OAuthToken length]) {
        [[AppDelegate sharedDelegate] setAndStoreFlickrAuthToken:nil secret:nil];
    }
    
    NSLog(@"%@", @"AUthenticating");
    
    //self.flickrRequest.sessionInfo = kFetchRequestTokenStep;
    [self.flickrRequest fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:SRCallbackURLBaseString]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
