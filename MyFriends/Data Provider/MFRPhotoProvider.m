//
//  MFRPhotoProvider.m
//  MyFriends
//
//  Created by Sapa Denys on 26.06.15.
//  Copyright (c) 2015 Sapa Denys. All rights reserved.
//

#import "MFRPhotoProvider.h"
#import "Friend.h"

@implementation MFRPhotoProvider

+ (void)imageFromURL:(NSString *)URL
   withAsociatedCell:(UITableViewCell *)cell
		   indexPath:(NSIndexPath *)indexPath
			andBlock:(void (^)(UIImage *image))fetchBlock
{
	if (fetchBlock) {
		cell.tag = indexPath.row;
		if (URL) {
			cell.imageView.image = nil;
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
			dispatch_async(queue, ^(void) {
				
				NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:URL]];
				
				UIImage* image = [[UIImage alloc] initWithData:imageData];
				if (image) {
					dispatch_async(dispatch_get_main_queue(), ^{
						if (cell.tag == indexPath.row) {
							cell.imageView.image = image;
							[cell setNeedsLayout];
						}
						fetchBlock(image);
					});
				}
			});
		}
	}
}

@end

