//
//  ChatView.h
//  HipsterChat
//
//  Created by Thomas Bouldin on 11/4/13.
//  Copyright (c) 2013 Thomas Bouldin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chat.h"

@interface ChatView : UICollectionViewCell
@property (nonatomic) IBOutlet UILabel *message;
@property (nonatomic) Chat *chat;
@end
