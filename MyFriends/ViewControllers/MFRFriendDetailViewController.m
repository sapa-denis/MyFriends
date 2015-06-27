//
//  MFRFriendDetailViewController.m
//  MyFriends
//
//  Created by Sapa Denys on 26.06.15.
//  Copyright (c) 2015 Sapa Denys. All rights reserved.
//

#import "MFRFriendDetailViewController.h"
#import "Friend.h"
#import "AppDelegate.h"

@interface MFRFriendDetailViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation MFRFriendDetailViewController

- (void)viewDidLoad
{
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	_managedObjectContext = [delegate managedObjectContext];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	_nameLabel.text = self.friendInfo.fullName;
	_phoneTextField.text = self.friendInfo.phone;
	_emailTextField.text = self.friendInfo.email;
	_photoImageView.image = [UIImage imageWithData:self.friendInfo.photo];
}

- (IBAction)saveButtonTouch:(id)sender
{
	self.friendInfo.phone = self.phoneTextField.text;
	self.friendInfo.email = self.emailTextField.text;
	
	NSError *error = nil;
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"%s Can not save friend: %@", __func__, error.localizedDescription);
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelButtonTouch:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([textField isEqual:self.phoneTextField]) {
		return self.emailTextField.becomeFirstResponder;
	} else if ([textField isEqual:self.emailTextField]) {
		return self.emailTextField.resignFirstResponder;
	}
	return YES;
}

@end
