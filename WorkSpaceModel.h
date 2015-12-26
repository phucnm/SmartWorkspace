//
//  WorkSpaceModel.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/17/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WorkSpaceModel : NSObject

@property (nonatomic) int id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *image_path;
@property (strong, nonatomic) NSString *thumb_path;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *ipaddr;
@property (nonatomic) double lon;
@property (nonatomic) double lat;
@property (strong, nonatomic) NSString *computer_name;
//@property (strong, nonatomic) NSString *address;
-(instancetype) encrypt;
-(instancetype) decrypt;
@end
