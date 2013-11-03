//
//  DetailViewController.h
//  HipsterChat
//
//  Created by Thomas Bouldin on 11/3/13.
//  Copyright (c) 2013 Thomas Bouldin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
