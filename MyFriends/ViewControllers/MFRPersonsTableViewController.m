//
//  MFRPersonsTableViewController.m
//  MyFriends
//
//  Created by Sapa Denys on 25.06.15.
//  Copyright (c) 2015 Sapa Denys. All rights reserved.
//

#import "MFRPersonsTableViewController.h"
#import <CoreData/CoreData.h>

#import "MFRRandomuserAPI.h"
#import "AppDelegate.h"
#import "Friend.h"
#import "MFRPhotoProvider.h"


static NSString *const kPersonsCellIdentifier = @"NewPersonCell";

@interface MFRPersonsTableViewController ()

@property (nonatomic, strong) NSMutableArray *personsArray;

@end

@implementation MFRPersonsTableViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	
	__weak MFRPersonsTableViewController* weakSelf = self;
	[MFRRandomuserAPI fetchNewPeopleWithSuccess:^(NSArray *newPeople) {
		weakSelf.personsArray = [NSMutableArray arrayWithArray:newPeople];
		[weakSelf.tableView reloadData];
	}
										failure:^(NSError *error) {
											NSLog(@"%s Fetch Error: %@", __func__, error.localizedDescription);
										}];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Friend *person = [self.personsArray objectAtIndex:indexPath.row];
	[person setIsFriend:YES];
	
	
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [delegate managedObjectContext];
	
	[context insertObject:person];
	
	NSError *error = nil;
	if (![context save:&error]) {
		NSLog(@"%s Can not save friend: %@", __func__, error.localizedDescription);
	}
	
	[self.personsArray removeObjectAtIndex:indexPath.row];
	[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.personsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPersonsCellIdentifier
															forIndexPath:indexPath];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:kPersonsCellIdentifier];
	}
	
	Friend *person = [self.personsArray objectAtIndex:indexPath.row];
	
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
							  }];
	}
	
	return cell;
	
}

@end
