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
#import "MFRPhotoProvider.h"

static NSString *const kFriendCellIdentifier = @"FriendCell";
static NSString *const kFriendsDetailSegueIdentifier = @"FriendDetailSegue";

@interface MFRFriendsListTableViewController ()

@property (nonatomic, strong) NSMutableArray *friendsArray;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end


@implementation MFRFriendsListTableViewController

- (void)viewDidLoad
{
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	_managedObjectContext = [delegate managedObjectContext];
}

- (void)viewWillAppear:(BOOL)animated
{
	__weak MFRFriendsListTableViewController *weakSelf = self;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([Friend class])];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"isFriend == 1"]];
	
	NSAsynchronousFetchRequest *asyncFetchRequest =
		[[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetchRequest
												 completionBlock:^(NSAsynchronousFetchResult *result) {
													 dispatch_async(dispatch_get_main_queue(), ^{
														 weakSelf.friendsArray = [NSMutableArray arrayWithArray:result.finalResult];
														 [weakSelf.tableView reloadData];
													 });
												 }];
	
	[self.managedObjectContext performBlock:^{
		NSError *error = nil;
		if (![self.managedObjectContext executeRequest:asyncFetchRequest error:&error]) {
			NSLog(@"Unable to execute asynchronous fetch result.");
			NSLog(@"%s Executing fetch request Error: %@", __func__, error.localizedDescription);
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
	
	NSData *photo = person.photo;
	
	if (photo) {
		cell.imageView.image = [UIImage imageWithData:photo];
	} else {
		[MFRPhotoProvider imageFromURL:person.photoULRString
					 withAsociatedCell:cell
							 indexPath:indexPath
							  andBlock:^(UIImage *image) {
								  
								  person.photo = UIImagePNGRepresentation(image);
								  
								  NSError *savingError = nil;
								  if (![self.managedObjectContext save:&savingError]) {
									  NSLog(@"Saving Error: %@", savingError.localizedDescription);
									  return;
								  }
							  }];
	}
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		Friend *deletedFriend = [self.friendsArray objectAtIndex:indexPath.row];
		deletedFriend.isFriend = NO;
		
		
		NSError *savingError = nil;
		if (![self.managedObjectContext save:&savingError]) {
			NSLog(@"Saving Error: %@", savingError.localizedDescription);
			return;
		}
		[self.friendsArray removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:@[indexPath]
						 withRowAnimation:UITableViewRowAnimationFade];
		
		
	}
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
