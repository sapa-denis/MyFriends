//
//  Friend.h
//  
//
//  Created by Sapa Denys on 25.06.15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSString * photoULRString;

- (void)fillFromDictionary:(NSDictionary *)mappedObj;

@end
