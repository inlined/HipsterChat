//
//  AppDelegate.m
//  HipsterChat
//
//  Created by Thomas Bouldin on 11/3/13.
//  Copyright (c) 2013 Thomas Bouldin. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatViewController.h"
#import <Parse/Parse.h>

@interface AppDelegate()<PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate> {
    ChatViewController *_chatViewController;
    UINavigationController *_navController;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"TsvcswckVymbVUOhPMkKsT6aGtdAqhdrvW6dBozH"
                  clientKey:@"pfgiB6GkK5Atgw4ZEFIUL53PkJRddqTUwvfHeRzZ"];
    
    // iOS 8:
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationSettings *settings =
          [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert |
                                                       UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound
                                            categories:nil];
        [application registerUserNotificationSettings:settings];
    
    // Pre iOS 8:
    } else {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert |
                                                        UIRemoteNotificationTypeBadge |
                                                        UIRemoteNotificationTypeSound];
        
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    _chatViewController = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
    _navController = [[UINavigationController alloc] initWithRootViewController:_chatViewController];
    
    if ([_navController.navigationBar respondsToSelector:@selector(setTranslucent:)]) {
        [_navController.navigationBar setTranslucent:NO];
    }
    
    if ([_navController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        [_navController.navigationBar setBarTintColor:[UIColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1.0f]];
    }
    
    self.window.rootViewController = _navController;
    
    PFLogInViewController *logInController = [[PFLogInViewController alloc] init];
    logInController.fields = PFLogInFieldsUsernameAndPassword|PFLogInFieldsLogInButton|PFLogInFieldsSignUpButton;
    logInController.delegate = self;
    logInController.signUpController.delegate = self;
    [_navController presentViewController:logInController animated:YES completion:NULL];
    
    return YES;
}

- (void)displayLoginFailureAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to log in"
                               message:@"Failed to log in. You will post as Anonymous Coward."
                              delegate:nil
                     cancelButtonTitle:@"Okay"
                     otherButtonTitles:nil];
     [alert show];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [_navController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    [_navController dismissViewControllerAnimated:YES completion:NULL];
    [self displayLoginFailureAlert];
}

- (void)logInViewController:(PFLogInViewController *)controller didLogInUser:(PFUser *)user {
    [_navController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    [_navController dismissViewControllerAnimated:YES completion:NULL];
    [self displayLoginFailureAlert];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register for remote notifications");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    if (handler != NULL) {
        NSLog(@"Received background push");
    }
    
    [_chatViewController refreshWithBlock:^(BOOL succeeded, NSError *error) {
        if (handler != NULL) {
            if (succeeded) {
                handler(UIBackgroundFetchResultNewData);
            } else {
                handler(UIBackgroundFetchResultFailed);
            }
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:NULL];
}

@end
