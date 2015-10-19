//
//  AppDelegate.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/16/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "AppDelegate.h"

NSString *SRCallbackURLBaseString = @"flickr://auth";

NSString *kFlickrName = @"Flickr";
NSString *kStoredAuthTokenKeyName = @"Flickr_AccessToken";
NSString *kStoredAuthTokenSecretKeyName = @"Flickr_AccessTokenSecret";

NSString *kDropboxName = @"Dropbox";
NSString *kDBTokenName = @"Dropbox_AccessToken";
NSString *kDBSecretName = @"Dropbox_AccessTokenSecret";

NSString *kGetAccessTokenStep = @"kGetAccessTokenStep";
NSString *kCheckTokenStep = @"kCheckTokenStep";


@interface AppDelegate ()

@end

@implementation AppDelegate

- (OFFlickrAPIRequest *)flickrRequest
{
    if (!_flickrRequest) {
        _flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
        _flickrRequest.delegate = self;
    }
    
    return _flickrRequest;
}

- (OFFlickrAPIContext *)flickrContext
{
    if (!_flickrContext) {
        _flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:@"9554333e337ada4ef13e7e8cb9f8ef48" sharedSecret:@"e9c6c0ef55418cb8"];
        
        NSString *authToken = [[NSUserDefaults standardUserDefaults] objectForKey:kStoredAuthTokenKeyName];
        NSString *authTokenSecret = [[NSUserDefaults standardUserDefaults] objectForKey:kStoredAuthTokenSecretKeyName];
        
        if (([authToken length] > 0) && ([authTokenSecret length] > 0)) {
            _flickrContext.OAuthToken = authToken;
            _flickrContext.OAuthTokenSecret = authTokenSecret;
        }
    }
    
    return _flickrContext;
}

+ (AppDelegate *)sharedDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)setAndStoreFlickrAuthToken:(NSString *)inAuthToken secret:(NSString *)inSecret
{
    if (![inAuthToken length] || ![inSecret length]) {
        self.flickrContext.OAuthToken = nil;
        self.flickrContext.OAuthTokenSecret = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFlickrName];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kStoredAuthTokenKeyName];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kStoredAuthTokenSecretKeyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    else {
        self.flickrContext.OAuthToken = inAuthToken;
        self.flickrContext.OAuthTokenSecret = inSecret;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFlickrName];
        [[NSUserDefaults standardUserDefaults] setObject:inAuthToken forKey:kStoredAuthTokenKeyName];
        [[NSUserDefaults standardUserDefaults] setObject:inSecret forKey:kStoredAuthTokenSecretKeyName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.

//    NSString *simulatePath = [[NSBundle mainBundle] pathForResource:@"db1" ofType:@"sqlite"];
//    NSLog(@"%@", simulatePath);
    
    [[IQKeyboardManager sharedManager] disableInViewControllerClass:[VENTouchLockCreatePasscodeViewController class]];
    [[IQKeyboardManager sharedManager] disableInViewControllerClass:[VENTouchLockEnterPasscodeViewController class]];
    
    
    [[VENTouchLock sharedInstance] setKeychainService:@"WSService"
                                      keychainAccount:@"LocalAccount"
                                        touchIDReason:@"Scan your fingerprint to use the app."
                                 passcodeAttemptLimit:5
                            splashViewControllerClass:[SampleLockSplashViewController class]];
    
    [FBSDKLoginButton class];
    [FBSDKProfilePictureView class];
    
    DBSession *session = [[DBSession alloc] initWithAppKey:@"4bmbuhjec0qkl9d" appSecret:@"2ju3wgm9r06hago" root:kDBRootDropbox];
    
    [DBSession setSharedSession:session];
    
    //Get and init db if dont exist, now WE ARE SIMULATE MORE DB IN A DEVICE, SO I'M LOAD A BUILT DB IN BUNDLE PATH
//    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *dbPath = [documentsPath stringByAppendingPathComponent:@"db.sqlite"];
//    NSLog(@"%@", documentsPath);
    
    //load DB1 by default
    self.simulateMode = @"db1";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *dbInDocumentPath = [documentsPath stringByAppendingPathComponent:@"db1.sqlite"];
        self.db = [FMDatabase databaseWithPath:dbInDocumentPath];
    }
    else
    {
        NSString *fileName;
        NSString *dbInDocumentPath;
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSError *error;
        for (int i = 1; i < 4; i++) {
            NSString *name = [NSString stringWithFormat:@"db%d", i];
            fileName = [NSString stringWithFormat:@"%@.sqlite", name];
            NSString *dbPath = [[NSBundle mainBundle] pathForResource:name ofType:@"sqlite"];

            dbInDocumentPath = [documentsPath stringByAppendingPathComponent:fileName];

            if (![[NSFileManager defaultManager] fileExistsAtPath:dbInDocumentPath]) {
                [[NSFileManager defaultManager] copyItemAtPath:dbPath toPath:dbInDocumentPath error:&error];
                if (error) {
                    NSLog(@"%@", error.localizedDescription);
                }
            }
            
        }

        if (!error) {
            FMDatabase *db = [FMDatabase databaseWithPath:[documentsPath stringByAppendingPathComponent:@"db1.sqlite"]];
            self.db = db;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else
            NSLog(@"%@", error.localizedDescription);
    }

    

    
    
    //This code below init a db when the app run the first time, now we dont need it. We have built db with tables, rows
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
//    {
//        // app already launched
//    }
//    else
//    {
//        if ([self.db open]) {
//            BOOL rc = [self.db executeUpdate:@"CREATE TABLE WORKSPACES(_id integer primary key autoincrement, name nvarchar(255), image_path nvarchar(255), thumb_path nvarchar(255), username nvarchar(255), password nvarchar(255), ipaddr nvarchar(255), lon double, lat double)"];
//            if (!rc) {
//                NSLog(@"%@", self.db.lastErrorMessage);
//            }
//            rc = [self.db executeUpdate:@"CREATE TABLE SERVICES(_id integer primary key autoincrement, type int, name nvarchar(255), icon_path nvarchar(255), access_token nvarchar(255), access_token_secret nvarchar(255), username nvarchar(255), password nvarchar(255))"];
//            
//            if (rc) {
//                rc = [self.db executeUpdate:@"INSERT INTO SERVICES(type, name, icon_path) VALUES(?,?,?)", [NSNumber numberWithInteger:FACEBOOK_OAUTH], @"Facebook", @"facebook"];
//                rc = [self.db executeUpdate:@"INSERT INTO SERVICES(type, name, icon_path) VALUES(?,?,?)", [NSNumber numberWithInteger:DROPBOX_OAUTH], @"Dropbox", @"dropbox"];
//                rc = [self.db executeUpdate:@"INSERT INTO SERVICES(type, name, icon_path) VALUES(?,?,?)", [NSNumber numberWithInteger:FLICKR_OAUTH], @"Flickr", @"flickr"];
//                rc = [self.db executeUpdate:@"INSERT INTO SERVICES(type, name, icon_path) VALUES(?,?,?)", [NSNumber numberWithInteger:FACEBOOK_WEB], @"Facebook web", @"facebook"];
//                rc = [self.db executeUpdate:@"INSERT INTO SERVICES(type, name, icon_path) VALUES(?,?,?)", [NSNumber numberWithInteger:YAHOO_WIN], @"Yahoo! Messenger", @"yahoo"];
//                rc = [self.db executeUpdate:@"INSERT INTO SERVICES(type, name, icon_path) VALUES(?,?,?)", [NSNumber numberWithInteger:SKYPE_WIN], @"Skype Desktop", @"skype"];
//            }
//   
//            [self.db close];
//            
//            // This is the first launch ever
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSLog(@"%@", url.scheme);
    NSString *strScheme = url.scheme;
    if ([strScheme isEqualToString:@"fb964083020269483"]) {
        return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    } else if ([strScheme isEqualToString:@"flickr"]) {
        if (![self flickrRequest].sessionInfo) {
            NSString *token = nil;
            NSString *verifier = nil;
            BOOL result = OFExtractOAuthCallback(url, [NSURL URLWithString:SRCallbackURLBaseString], &token, &verifier);
            
            if (!result) {
                NSLog(@"Cannot obtain token/secret from URL: %@", [url absoluteString]);
                return NO;
            }
            
            self.flickrRequest.sessionInfo = kGetAccessTokenStep;
            [self.flickrRequest fetchOAuthAccessTokenWithRequestToken:token verifier:verifier];
            
            return YES;
            
        }
    } else {
        if ([[DBSession sharedSession] handleOpenURL:url]) {
            if ([[DBSession sharedSession] isLinked]) {
                NSLog(@"App linked successfully!");
                NSLog(@"%@", [url absoluteString]);
                NSString *userId = [[DBSession sharedSession].userIds objectAtIndex:0];
                MPOAuthCredentialConcreteStore *credentials = [[DBSession sharedSession] credentialStoreForUserId:userId];
                NSLog(@"%@", credentials.accessToken);
                /* Set UserDefaults  */
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDropboxName];
                [[NSUserDefaults standardUserDefaults] setObject:credentials.accessToken forKey:kDBTokenName];
                [[NSUserDefaults standardUserDefaults] setObject:credentials.accessTokenSecret forKey:kDBSecretName];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DropboxLogin" object:nil];
                return YES;
                // At this point you can start making API calls
            }
        }
    }
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    self._showingPasscode = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    if ([DMPasscode isPasscodeSet] && !self._showingPasscode) {
//        self._showingPasscode = YES;
//        [DMPasscode showPasscodeInViewController:self.window.rootViewController completion:^(BOOL success, NSError *error) {
//            if (success) {
//                NSLog(@"OK");
//            }else{
//                
//                NSLog(@"Auth failed");
//            }
//        }];
//    }

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark OFFlickrAPIRequest delegate methods

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID
{
    [self setAndStoreFlickrAuthToken:inAccessToken secret:inSecret];
    self.flickrUserName = inUserName;

    [self flickrRequest].sessionInfo = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FlickrLogin" object:nil];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    if (inRequest.sessionInfo == kCheckTokenStep) {
        self.flickrUserName = [inResponseDictionary valueForKeyPath:@"user.username._text"];
    }
    
    [self flickrRequest].sessionInfo = nil;
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    if (inRequest.sessionInfo == kGetAccessTokenStep) {
    }
    else if (inRequest.sessionInfo == kCheckTokenStep) {
        [self setAndStoreFlickrAuthToken:nil secret:nil];
    }
}


@end
