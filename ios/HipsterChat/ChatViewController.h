//
//  ChatViewController.h
//  HipsterChat
//
//  Created by Ben Nham on 11/5/13.
//  Copyright (c) 2013 Thomas Bouldin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ChatViewController : UIViewController
- (void)refreshWithBlock:(PFBooleanResultBlock)block;
@end
