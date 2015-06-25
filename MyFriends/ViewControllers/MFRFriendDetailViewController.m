//
//  MFRFriendDetailViewController.m
//  MyFriends
//
//  Created by Sapa Denys on 26.06.15.
//  Copyright (c) 2015 Sapa Denys. All rights reserved.
//

#import "MFRFriendDetailViewController.h"
#import "Friend.h"

@interface MFRFriendDetailViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation MFRFriendDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	_nameLabel.text = self.friendInfo.fullName;
	_phoneTextField.text = self.friendInfo.phone;
	_emailTextField.text = self.friendInfo.email;
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
