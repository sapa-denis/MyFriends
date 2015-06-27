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

@interface MFRFriendsListTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSMutableArray *friendsArray;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end


@implementation MFRFriendsListTableViewController

- (void)viewDidLoad
{
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	_managedObjectContext = [delegate managedObjectContext];
	
	__weak MFRFriendsListTableViewController *weakSelf = self;
	[[[self fetchedResultsController] managedObjectContext] performBlock:^{
		NSError *error;
		if (![[self fetchedResultsController] performFetch:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		} else {
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{
				[weakSelf.tableView reloadData];
			}];
		}
	}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendCellIdentifier
															forIndexPath:indexPath];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:kFriendCellIdentifier];
	}
	
	[self configureCell:cell atIndexPath:indexPath];
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
		
		[self.tableView beginUpdates];
		Friend *deletedFriend = [self.fetchedResultsController objectAtIndexPath:indexPath];
		deletedFriend.isFriend = NO;
		
		NSError *savingError = nil;
		if (![self.managedObjectContext save:&savingError]) {
			NSLog(@"Saving Error: %@", savingError.localizedDescription);
			return;
		}
		[self.friendsArray removeObjectAtIndex:indexPath.row];
		
		[tableView deleteRowsAtIndexPaths:@[indexPath]
						 withRowAnimation:UITableViewRowAnimationFade];
		
		[self.tableView endUpdates];
	}
}

#pragma mark -

- (void)configureCell:(UITableViewCell *)cell
		  atIndexPath:(NSIndexPath *)indexPath
{
	Friend *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		[self.tableView beginUpdates];
	}];
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
 
	UITableView *tableView = self.tableView;
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		switch(type) {
				
			case NSFetchedResultsChangeInsert:
				[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
								 withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeDelete:
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
								 withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeUpdate:
				[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
				break;
				
			case NSFetchedResultsChangeMove:
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
								 withRowAnimation:UITableViewRowAnimationFade];
				[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
								 withRowAnimation:UITableViewRowAnimationFade];
				break;
		}
	}];
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id )sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		switch(type) {
				
			case NSFetchedResultsChangeInsert:
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeDelete:
				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			default:
				break;
		}
	}];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		[self.tableView endUpdates];
	}];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
	if ([segue.identifier isEqualToString:kFriendsDetailSegueIdentifier]) {
		MFRFriendDetailViewController *destination = [segue destinationViewController];
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		destination.friendInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
}

#pragma mark - CoreData

- (NSFetchedResultsController *)fetchedResultsController {
 
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
 
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Friend class])
											  inManagedObjectContext:self.managedObjectContext];
	
	[fetchRequest setEntity:entity];
 
	NSSortDescriptor *sort = [[NSSortDescriptor alloc]
							  initWithKey:@"lastName" ascending:YES];
	
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"isFriend == 1"]];
	[fetchRequest setSortDescriptors:@[sort]];
	[fetchRequest setFetchBatchSize:20];
 
	NSFetchedResultsController *theFetchedResultsController =
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
										managedObjectContext:self.managedObjectContext
										  sectionNameKeyPath:nil
												   cacheName:nil];
	
	_fetchedResultsController = theFetchedResultsController;
	_fetchedResultsController.delegate = self;
 
	return _fetchedResultsController;
 
}


@end
