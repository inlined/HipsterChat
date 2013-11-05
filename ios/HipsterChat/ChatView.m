//
//  ChatView.m
//  HipsterChat
//
//  Created by Thomas Bouldin on 11/4/13.
//  Copyright (c) 2013 Thomas Bouldin. All rights reserved.
//

#import "ChatView.h"

// cache for margins configured via constraints in XIB
static CGSize _extraMargins = {0,0};

@implementation ChatView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setChat:(Chat *)chat {
    self.message.text = chat.text;
    if ([chat.author.objectId isEqualToString:[PFUser currentUser].objectId]) {
        self.message.backgroundColor = [UIColor blueColor];
    }
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [self.message intrinsicContentSize];
    
    if (CGSizeEqualToSize(_extraMargins, CGSizeZero))
    {
        // quick and dirty: get extra margins from constraints
        for (NSLayoutConstraint *constraint in self.constraints)
        {
            if (constraint.firstAttribute == NSLayoutAttributeBottom || constraint.firstAttribute == NSLayoutAttributeTop)
            {
                // vertical spacer
                _extraMargins.height += [constraint constant];
            }
            else if (constraint.firstAttribute == NSLayoutAttributeLeading || constraint.firstAttribute == NSLayoutAttributeTrailing)
            {
                // horizontal spacer
                _extraMargins.width += [constraint constant];
            }
        }
    }
    
    // add to intrinsic content size of label
    size.width += _extraMargins.width;
    size.height += _extraMargins.height;
    
    return size;
}

@end
