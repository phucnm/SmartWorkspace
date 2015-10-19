//
//  ServiceModel.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 7/5/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SERVICE_TYPE) {
    FACEBOOK_OAUTH = 0,
    DROPBOX_OAUTH  = 1,
    FLICKR_OAUTH   = 2,
    FACEBOOK_WEB   = 3,
    GMAIL_WEB      = 4,
    YAHOO_WIN      = 5,
    SKYPE_WIN      = 6
};

@interface ServiceModel : NSObject

@property (nonatomic) int id;
@property (nonatomic) SERVICE_TYPE type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icon_path;
@property (nonatomic, strong) NSString *access_token;
@property (nonatomic, strong) NSString *access_token_secret;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
- (instancetype) initWithType:(SERVICE_TYPE)type andName:(NSString*) name andIcon:(NSString*) icon;
-(instancetype) encrypt;
-(instancetype) decrypt;
@end
