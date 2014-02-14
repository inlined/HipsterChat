//
//  asdf.m
//  HipsterChat
//
//  Created by Thomas Bouldin on 12/5/13.
//  Copyright (c) 2013 Thomas Bouldin. All rights reserved.
//

#import "asdf.h"

@implementation asdf

- (id)initWithFrame:(CGRect)frame
{
    PFQuery *myFriends = [Friendships query];
    [myFriends whereKey:@"fromUser" equalTo:PFUser.currentUser];

    PFQuery *yourFriends =[Friendships query];
    [myFriends whereKey:@"fromUser" equalTo:you];
    
  

    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
