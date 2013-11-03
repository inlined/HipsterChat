//
//  MasterViewController.h
//  HipsterChat
//
//  Created by Thomas Bouldin on 11/3/13.
//  Copyright (c) 2013 Thomas Bouldin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
