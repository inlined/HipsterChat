//
//  ChatViewController.m
//  HipsterChat
//
//  Created by Ben Nham on 11/5/13.
//  Copyright (c) 2013 Thomas Bouldin. All rights reserved.
//

#import "ChatViewController.h"
#import "Chat.h"

static CGFloat kVerticalPadding = 4;
static CGFloat kHorizontalPadding = 5;

static CGFloat kAuthorHeight = 15;
static CGFloat kAuthorSpacing = 2;
static CGFloat kDateHeight = 15;
static CGFloat kDateSpacing = 2;

static CGFloat kTextFieldHeight = 35;

#pragma mark - ChatViewTableCell

@interface ChatTableViewCell : UITableViewCell {
    UILabel *_authorLabel;
    UILabel *_textLabel;
    UILabel *_dateLabel;
}
@end

@implementation ChatTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        UIView *contentView = [self contentView];
        
        _authorLabel = [[UILabel alloc] init];
        _authorLabel.font = [UIFont boldSystemFontOfSize:14];
        _authorLabel.textColor = [UIColor colorWithRed:87.0/255 green:107.0/255 blue:149.0/255 alpha:1.0];
        [contentView addSubview:_authorLabel];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.numberOfLines = 0;
        [contentView addSubview:_textLabel];
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont systemFontOfSize:12];
        _dateLabel.textColor = [UIColor grayColor];
        [contentView addSubview:_dateLabel];
        
        [contentView addSubview:_textLabel];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = CGRectInset(self.bounds, kHorizontalPadding, kVerticalPadding);
    
    CGRect authorFrame = bounds;
    authorFrame.size.height = kAuthorHeight;
    _authorLabel.frame = authorFrame;
    
    CGRect textLabelFrame = bounds;
    textLabelFrame.origin.y = CGRectGetMaxY(authorFrame) + kAuthorSpacing;
    textLabelFrame.size.height = bounds.size.height - kAuthorHeight - kAuthorSpacing - kDateHeight - kDateSpacing;
    _textLabel.frame = textLabelFrame;
    
    CGRect dateFrame = bounds;
    dateFrame.origin.y = CGRectGetMaxY(bounds) - kDateHeight;
    dateFrame.size.height = kDateHeight;
    _dateLabel.frame = dateFrame;
}

- (void)setAuthor:(NSString *)author text:(NSString *)text date:(NSDate *)date {
    static NSDateFormatter *__formatter = nil;
    if (__formatter == nil) {
        __formatter = [[NSDateFormatter alloc] init];
        [__formatter setDateStyle:NSDateFormatterShortStyle];
        [__formatter setTimeStyle:NSDateFormatterShortStyle];
        [__formatter setDoesRelativeDateFormatting:YES];
    }
    
    _authorLabel.text = author;
    _textLabel.text = text;
    _dateLabel.text = [__formatter stringFromDate:date];
}

+ (CGFloat)heightForText:(NSString *)text {
    UILabel *__sizingLabel;
    if (__sizingLabel == nil) {
        __sizingLabel = [[UILabel alloc] init];
        __sizingLabel.font = [UIFont systemFontOfSize:14];
        __sizingLabel.numberOfLines = 0;
    }
    
    CGRect rect = CGRectInset([UIScreen mainScreen].bounds, kHorizontalPadding, 0);
    __sizingLabel.text = text;
    
    return [__sizingLabel sizeThatFits:rect.size].height + kAuthorHeight + kAuthorSpacing + kDateHeight + kDateSpacing + 2 * kVerticalPadding;
}

@end


#pragma mark - ChatViewController

@interface ChatViewController()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSArray *_messages;
    UITableView *_tableView;
    UIView *_entryContainerView;
    UIView *_separatorView;
    UITextField *_entryField;
    CGRect _keyboardFrame;
}
@end

@implementation ChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = @"HipsterChat";
        
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(keyboardWillShow:)
                   name:UIKeyboardWillShowNotification object:nil];
        
        [nc addObserver:self
               selector:@selector(keyboardWillHide:)
                   name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsSelection = NO;
    
    if ([_tableView respondsToSelector:@selector(setKeyboardDismissMode:)]) {
        [_tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
    }
    
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0, kHorizontalPadding, 0, kHorizontalPadding)];
    }
    
    _entryField = [[UITextField alloc] initWithFrame:CGRectZero];
    _entryField.delegate = self;
    _entryField.placeholder = @"Message";
    _entryField.font = [UIFont systemFontOfSize:14];
    _entryField.returnKeyType = UIReturnKeySend;
    
    _separatorView = [[UIView alloc] initWithFrame:CGRectZero];
    _separatorView.backgroundColor = [UIColor colorWithRed:178.0/255 green:178.0/255 blue:178.0/255 alpha:1.0];
    
    _entryContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    _entryContainerView.backgroundColor = [UIColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1.0f];
    [_entryContainerView addSubview:_separatorView];
    [_entryContainerView addSubview:_entryField];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    containerView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:_tableView];
    [containerView addSubview:_entryContainerView];
    
    self.view = containerView;
}

- (void)viewDidLayoutSubviews {
    CGRect bounds = self.view.bounds;
    bounds.size.height -= _keyboardFrame.size.height;
    
    CGRect tableViewFrame = bounds;
    tableViewFrame.size.height -= kTextFieldHeight;
    
    CGRect textFieldFrame = bounds;
    textFieldFrame.origin.y = CGRectGetMaxY(bounds) - kTextFieldHeight;
    textFieldFrame.size.height = kTextFieldHeight;
    
    [_tableView setFrame:tableViewFrame];
    [_entryContainerView setFrame:textFieldFrame];
    [_separatorView setFrame:CGRectMake(0, 0, bounds.size.width, 0.5)];
    [_entryField setFrame:CGRectInset(_entryContainerView.bounds, kHorizontalPadding, kVerticalPadding)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshWithBlock:NULL];
}

- (void)refreshWithBlock:(PFBooleanResultBlock)block {
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error querying objects: %@", error);
        } else {
            _messages = [objects copy];
            [_tableView reloadData];
        }
        
        if (block != NULL) {
            block(error != nil, error);
        }
    }];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ReuseIdentifier = @"ChatTableViewCell";
    ChatTableViewCell *cell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    
    if (cell == nil) {
        cell = [[ChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReuseIdentifier];
    }
    
    Chat *chat = _messages[indexPath.row];
    NSString *username = [chat author].username ?: @"Anonymous Coward";
    [cell setAuthor:username text:chat.text date:chat.updatedAt];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Chat *chat = _messages[indexPath.row];
    return [ChatTableViewCell heightForText:chat.text];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([textField.text length] != 0) {
        Chat *chat = [[Chat alloc] init];
        chat.author = [PFUser currentUser];
        chat.text = textField.text;
        
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self refreshWithBlock:NULL];
            } else {
                NSLog(@"Failed to save object: %@", error);
            }
        }];
    }
    
    textField.text = nil;
    return YES;
}

#pragma mark -
#pragma mark Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger curve = [info[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    _keyboardFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [self.view setNeedsLayout];
    
    [UIView beginAnimations:@"keyboard-show" context:NULL];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:duration];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, _keyboardFrame.size.height, 0);
    _tableView.contentInset = inset;
    _tableView.scrollIndicatorInsets = inset;
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSUInteger curve = [info[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    _keyboardFrame = CGRectZero;
    
    [self.view setNeedsLayout];
    
    [UIView beginAnimations:@"keyboard-hide" context:NULL];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:duration];
    
    _tableView.contentInset = UIEdgeInsetsZero;
    _tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

@end
