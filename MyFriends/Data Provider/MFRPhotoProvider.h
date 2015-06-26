//
//  MFRPhotoProvider.h
//  MyFriends
//
//  Created by Sapa Denys on 26.06.15.
//  Copyright (c) 2015 Sapa Denys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Friend;

@interface MFRPhotoProvider : NSObject

+ (void)imageFromURL:(NSString *)URL
   withAsociatedCell:(UITableViewCell *)cell
		   indexPath:(NSIndexPath *)indexPath
			andBlock:(void (^)(UIImage *image))fetchBlock;

@end
