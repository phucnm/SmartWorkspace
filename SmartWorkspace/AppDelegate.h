//
//  AppDelegate.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/16/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, OFFlickrAPIRequestDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FMDatabase *db;
@property (strong, nonatomic) NSString *simulateMode;
@property (nonatomic, strong) OFFlickrAPIContext *flickrContext;
@property (nonatomic, strong) NSString *flickrUserName;
@property (nonatomic, strong) OFFlickrAPIRequest *flickrRequest;
@property (nonatomic) BOOL _showingPasscode;
+(AppDelegate*) sharedDelegate;
- (void)setAndStoreFlickrAuthToken:(NSString *)inAuthToken secret:(NSString *)inSecret;
extern NSString *SRCallbackURLBaseString;
@end

