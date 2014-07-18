//
//  SinglePerson.h
//  Notebook2
//
//  Created by Sergey on 7/15/14.
//  Copyright (c) 2014 sandbox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SinglePerson : NSObject

@property (strong, atomic) NSString* name;

@property (strong, atomic) NSString* lastName;

@property (strong, atomic) NSString* number;

- (SinglePerson*)initWithName:(NSString*)aName
             lastName:(NSString*)lastname
               phoneNumber:(NSString*)number;

- (NSComparisonResult)compareByName:(SinglePerson*)otherObject;

- (NSComparisonResult)compareByLastName:(SinglePerson*)otherObject;

- (SinglePerson*)randomPerson;

- (NSData*)serialize;

- (BOOL)unserialize:(NSString*)src;

@end
