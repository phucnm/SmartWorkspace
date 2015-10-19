//
//  ActionViewController.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 7/7/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "ActionViewController.h"

@interface ActionViewController() <CNPGridMenuDelegate>
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [AFHTTPRequestOperationManager manager];
    
    NSArray *services = [[ServiceManager sharedManager] selectAll];
    
    NSMutableArray *items = [NSMutableArray array];
    
    for (ServiceModel* service in services) {
        CNPGridMenuItem *item = [[CNPGridMenuItem alloc] init];
        item.icon = [UIImage imageNamed:service.icon_path];
        item.title = service.name;
        item.isTapped = NO;
        item.tag = service;
    }

    
    CNPGridMenu *gridMenu = [[CNPGridMenu alloc] initWithMenuItems:items];
    gridMenu.delegate = self;
    [self presentGridMenu:gridMenu animated:YES completion:^{
        NSLog(@"Grid Menu Presented");
    }];

}

- (void)gridMenuDidTapOnBackground:(CNPGridMenu *)menu {
    
}

-(void)gridMenu:(CNPGridMenu *)menu didTapOnItem:(CNPGridMenuItem *)item {
    ServiceModel *service = item.tag;
    
    switch (service.type) {
        case YAHOO_WIN: {
            
        }
            break;
        case SKYPE_WIN: {
            
        }
            break;
        case FACEBOOK_WEB: {
            
        }
            break;
        default:
            break;
    }
}

- (void) loginYahoo:(NSString*) username :(NSString*) password andItem:(CNPGridMenuItem*) item {
    NSString *host = [NSString stringWithFormat:@"%@%@",self.ipaddr,@":3000/yahoo/login"];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[username, password] forKeys:@[@"username", @"password"]];
    [self.manager POST:host parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        item.isTapped = !item.isTapped;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

- (void) logoutYahoo:(CNPGridMenuItem*) item {
    NSString *host = [NSString stringWithFormat:@"%@%@",self.ipaddr,@":3000/yahoo/logout"];
    [self.manager GET:host parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        item.isTapped = !item.isTapped;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}

@end
