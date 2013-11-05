//
//  ChatViewController.m
//  HipsterChat
//
//  Created by Thomas Bouldin on 11/4/13.
//  Copyright (c) 2013 Thomas Bouldin. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatView.h"
#import "Chat.h"
#import "AppDelegate.h"

@interface ChatViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property ChatView *sizingView;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [AppDelegate setChatViewController:self];
    self.objects = [@[] mutableCopy];
    self.sizingView = [[ChatView alloc] init];
    [self refresh];
}

- (void)refresh {
    [[self query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error querying objects: %@", error);
            return;
        }
        
        NSLog(@"Finished querying for results");
        [self.objects removeAllObjects];
        [self.objects addObjectsFromArray:objects];
        [self.collectionView reloadData];
        [self.collectionView setNeedsDisplay];
    }];
}

+ (PFQuery *)query {
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query orderByDescending:@"createdAt"];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    return query;
}

- (PFQuery *)query {
    PFQuery *query = [[self class] query];
    if ([self.objects count]) {
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
    } else {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    return query;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.objects.count;
}

- (Chat *)objectAtIndexPath:(NSIndexPath *)indexPath {
    return self.objects[indexPath.row];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChatView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"chat" forIndexPath:indexPath];
    Chat *chat = [self objectAtIndexPath:indexPath];
    cell.chat = chat;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //   self.sizingView.chat = [self objectAtIndexPath:indexPath];
    //return [self.sizingView intrinsicContentSize];
    return CGSizeMake(self.view.bounds.size.width, 40);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
