//
//  MFRRandomuserAPI.m
//  MyFriends
//
//  Created by Sapa Denys on 25.06.15.
//  Copyright (c) 2015 Sapa Denys. All rights reserved.
//

#import "MFRRandomuserAPI.h"
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import "Friend.h"


@implementation MFRRandomuserAPI

+(void)fetchNewPeopleWithSuccess:(void (^)(NSArray *))handle
						 failure:(void (^)(NSError *))failure
{
	NSString *url = @"http://api.randomuser.me/";
	AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc]
											  initWithBaseURL:[NSURL URLWithString:url]];
	
	NSManagedObjectContext *context;
	AppDelegate *delegate = [[UIApplication sharedApplication] delegate];

	context = [delegate managedObjectContext];
	
	NSDictionary *parametrs = @{ @"results" : @"20" };
	
	[manager GET:@""
	  parameters:parametrs
		 success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
			 
			 NSLog(@"%@", responseObject);
			 
			 NSMutableArray *personsObjects = [NSMutableArray arrayWithArray:@[]];
			 
			 NSArray *offers = [responseObject objectForKey:@"results"];
			 [offers enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
				 
				 
				 NSEntityDescription *friendEntity = [NSEntityDescription entityForName:NSStringFromClass([Friend class])
																inManagedObjectContext:context];
				 
				 Friend *newPerson = (Friend *)[[NSManagedObject alloc] initWithEntity:friendEntity
														insertIntoManagedObjectContext:nil];
				 [newPerson fillFromDictionary:obj];
				 
				 [personsObjects addObject:newPerson];
			 }];
			 
			 handle(personsObjects);
		 }
		 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			 failure(error);
		 }];

}

@end
