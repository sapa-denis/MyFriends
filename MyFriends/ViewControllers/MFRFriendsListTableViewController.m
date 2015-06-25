//
//  ViewController.m
//  MyFriends
//
//  Created by Sapa Denys on 24.06.15.
//  Copyright (c) 2015 Sapa Denys. All rights reserved.
//

#import "MFRFriendsListTableViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Friend.h"
#import "MFRFriendDetailViewController.h"

static NSString *const kFriendCellIdentifier = @"FriendCell";
static NSString *const kFriendsDetailSegueIdentifier = @"FriendDetailSegue";

@interface MFRFriendsListTableViewController ()

@property (nonatomic, strong) NSArray *friendsArray;

@end


@implementation MFRFriendsListTableViewController

- (void)viewWillAppear:(BOOL)animated
{
	__weak MFRFriendsListTableViewController *weakSelf = self;
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [delegate managedObjectContext];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([Friend class])];
	NSAsynchronousFetchRequest *asyncFetchRequest =
		[[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetchRequest
												 completionBlock:^(NSAsynchronousFetchResult *result) {
													 dispatch_async(dispatch_get_main_queue(), ^{
														 weakSelf.friendsArray = result.finalResult;
														 [weakSelf.tableView reloadData];
													 });
												 }];
	
	
	
	[context performBlock:^{
		NSError *error = nil;
		if (![context executeRequest:asyncFetchRequest error:&error]) {
			NSLog(@"Unable to execute asynchronous fetch result.");
			NSLog(@"%s, %@", __func__, error.localizedDescription);
		}
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.friendsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendCellIdentifier
															forIndexPath:indexPath];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:kFriendCellIdentifier];
	}
	
	Friend *person = [self.friendsArray objectAtIndex:indexPath.row];
	
	cell.textLabel.text = person.fullName;
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
	if ([segue.identifier isEqualToString:kFriendsDetailSegueIdentifier]) {
		MFRFriendDetailViewController *destination = [segue destinationViewController];
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		destination.friendInfo = [self.friendsArray objectAtIndex:indexPath.row];
	}
}


@end
