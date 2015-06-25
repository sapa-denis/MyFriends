//
//  MFRPersonsTableViewController.m
//  MyFriends
//
//  Created by Sapa Denys on 25.06.15.
//  Copyright (c) 2015 Sapa Denys. All rights reserved.
//

#import "MFRPersonsTableViewController.h"
#import "MFRRandomuserAPI.h"
#import "Friend.h"

static NSString * const kPersonsCellIdentifier = @"NewPersonCell";

@interface MFRPersonsTableViewController ()

@property (nonatomic, strong) NSArray *personsArray;

@end

@implementation MFRPersonsTableViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	
	__weak MFRPersonsTableViewController* weakSelf = self;
	[MFRRandomuserAPI fetchNewPeopleWithSuccess:^(NSArray *newPeople) {
		weakSelf.personsArray = newPeople;
		[weakSelf.tableView reloadData];
	}
										failure:^(NSError *error) {
											NSLog(@"%s Fetch Error: %@", __func__, error);
										}];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 65;
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
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", person.lastName, person.firstName];
	
	return cell;
	
}

@end
