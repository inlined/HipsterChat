//
//  MasterViewController.m
//  HipsterChat
//
//  Created by Thomas Bouldin on 11/3/13.
//  Copyright (c) 2013 Thomas Bouldin. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController () <PFLogInViewControllerDelegate>
@property NSMutableArray *objects;
@end

@implementation MasterViewController


// Super implementation is actually mutable
@dynamic objects;

#pragma mark - User login
- (void)viewDidAppear:(BOOL)animated {
    if (![PFUser currentUser]) {
        PFLogInViewController *loginVC = [[PFLogInViewController alloc] init];
        loginVC.fields = PFLogInFieldsFacebook;
        loginVC.delegate = self;
        [self presentViewController:loginVC animated:NO completion:nil];
    }
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [logInController dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"Must log in to continue");
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in user; must retry");
}

#pragma mark - Live Data
- (void)awakeFromNib
{
    self.parseClassName = @"Message";
    self.textKey = @"text";

    [super awakeFromNib];
}

@end
