//
//  DBViewController.m
//  SmartWorkspace
//
//  Created by Phuc Nguyen on 6/16/15.
//  Copyright (c) 2015 PHUCNGUYEN. All rights reserved.
//

#import "DBViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface DBViewController () <DBRestClientDelegate>
@property (weak, nonatomic) IBOutlet UILabel *tokenView;
@property (weak, nonatomic) IBOutlet UIButton *dbLinkButton;
@property (strong, nonatomic) DBRestClient *dbRestClient;
@property (strong, nonatomic) NSString *userId;
@end

@implementation DBViewController

NSString* dbName = @"Dropbox";

- (IBAction)btnClicked:(id)sender {
//    NSURL *url = [NSURL URLWithString:@"https://api.dropbox.com/1/account/info"];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    //DBRequest* request =[[DBRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidLoaded:)];
    
    //request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:root, @"root", nil];
    
//    [self.dbRestClient->requests addObject:request];
}

- (void)requestDidLoaded:(DBRequest *)request {
    if (request.error) {
        NSLog(@"failed");
    } else {
        NSDictionary* result = (NSDictionary*)[request resultJSON];
        //DBAccountInfo* accountInfo = [[DBAccountInfo alloc] initWithDictionary:result];
        NSLog(@"%@", result);
    }
}

- (void)restClient:(DBRestClient *)client loadedAccountInfo:(DBAccountInfo *)info {
    NSLog(@"%@", info.userId);
    self.userId = info.userId;
}

- (IBAction)dbLinkClicked:(id)sender {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    } else {
        [[DBSession sharedSession] unlinkAll];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:dbName];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_AccessToken", dbName]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_AccessTokenSecret", dbName]];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
}
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if(metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for(DBMetadata *file in metadata.contents) {
            NSLog(@"t%@", file.filename);
        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if ([[DBSession sharedSession] isLinked]) {
        

        [self.dbLinkButton setTitle:@"Dropbox unlink" forState:UIControlStateNormal];
         
         /* */
        self.tokenView.text = @"Linked";

//        [self.dbRestClient loadMetadata:@"/"];
    } else {
        [self.dbLinkButton setTitle:@"Dropbox link" forState:UIControlStateNormal];
        
        self.tokenView.text = @"Un linked";

        /* Set UserDefaults  */
        
        
        
        /* */
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dbRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.dbRestClient.delegate = self;
    [self.tokenView sizeToFit];
    
//    if ([[DBSession sharedSession] isLinked]) {
//        self.tokenView.text = @"Linked";
//    } else {
//        self.tokenView.text = @"Un linked";
//    }
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
