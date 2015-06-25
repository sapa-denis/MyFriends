//
//  Friend.m
//  
//
//  Created by Sapa Denys on 25.06.15.
//
//

#import "Friend.h"

@interface Friend ()

@end

@implementation Friend

@dynamic firstName;
@dynamic lastName;
@dynamic phone;
@dynamic email;
@dynamic photo;
@dynamic photoULRString;
@dynamic isFriend;

- (void)fillFromDictionary:(NSDictionary *)mappedObj
{
	NSDictionary *userInfo = [mappedObj objectForKey:@"user"];
	NSDictionary *fullName = [userInfo objectForKey:@"name"];
	NSDictionary *photos = [userInfo objectForKey:@"picture"];
	
	self.firstName = [fullName objectForKey:@"first"];
	self.firstName = [self.firstName capitalizedStringWithLocale:[NSLocale currentLocale]];
	
	self.lastName = [fullName objectForKey:@"last"];
	self.lastName = [self.lastName capitalizedStringWithLocale:[NSLocale currentLocale]];
	
	self.phone = [userInfo objectForKey:@"cell"];
	self.email = [userInfo objectForKey:@"email"];
	self.photoULRString = [photos objectForKey:@"thumbnail"];
	self.isFriend = NO;
}

- (NSString *)fullName
{
	return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
