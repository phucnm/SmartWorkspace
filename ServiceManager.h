//
//  ServiceManager.h
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 7/7/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceModel.h"
#import "AppDelegate.h"

@interface ServiceManager : NSObject

+(id) sharedManager;
-(NSArray*) selectAll;
-(BOOL) addOne:(ServiceModel*) ws;
-(BOOL) updateOne:(ServiceModel*) ws;
-(BOOL) deleteOneWithId:(int) id;

@end
