//
//  MFRRandomuserAPI.h
//  MyFriends
//
//  Created by Sapa Denys on 25.06.15.
//  Copyright (c) 2015 Sapa Denys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFRRandomuserAPI : NSObject

+ (void)fetchNewPeopleWithSuccess:(void (^)(NSArray *newPeople))handle
						  failure:(void (^)(NSError *error))failure;

@end
