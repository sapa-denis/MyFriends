//
//  MFRFriendDetailViewController.h
//  MyFriends
//
//  Created by Sapa Denys on 26.06.15.
//  Copyright (c) 2015 Sapa Denys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Friend;

@interface MFRFriendDetailViewController : UITableViewController

@property (nonatomic, weak) Friend *friendInfo;

@end
