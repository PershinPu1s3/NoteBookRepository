//
//  SinglePerson.m
//  Notebook2
//
//  Created by Sergey on 7/15/14.
//  Copyright (c) 2014 sandbox. All rights reserved.
//

#import "SinglePerson.h"



NSArray* possibleNames;// = [NSArray arrayWithObjects:@"String1",@"String2",@"String3",nil ];
NSArray* possibleLastNames;



@implementation SinglePerson

- (SinglePerson*)initWithName: (NSString*)name lastName: (NSString*)lastname phoneNumber:(NSString*)number
{
   
    self.name = name;
    self.lastName = lastname;
    self.number = number;
    
    
    return self;
}


- (SinglePerson*)randomPerson
{
    possibleNames = [NSArray arrayWithObjects:
                     @"Alexander",@"Adolf",@"Andrew",
                     @"Bob",@"Kate",@"Bryan",
                     @"James",@"Cella",@"Cecil",
                     @"Diana",@"Claud",@"Anna",
                     @"Sergey",@"John",@"Ronald",
                     @"William",@"Thomas",@"Christopher",
                     @"Linda",@"Mary",@"Christie",
                     @"Sean",@"Robert",@"Carl",
                     @"Martin",@"Ivan",@"Paul",
                     @"Angelina",@"Ellen",@"George",nil ];
    
    possibleLastNames =  [NSArray arrayWithObjects:@"Stuart",@"Rosenberg",@"Stone",
                          @"Potter",@"Johnson",@"Richardson",
                          @"mcClaud",@"mcBryan",@"Stonton",
                          @"Smith",@"Clinton",@"Bush",
                          @"Monroe",@"Brook",@"House",
                          @"Killer",@"Anderson",@"Messenger",
                          @"Jobs",@"Gates",@"Page",
                          @"Plant",@"Jones",@"Cobain", nil];

    self.name = [possibleNames objectAtIndex:arc4random_uniform([possibleNames count])];
    self.lastName = [possibleLastNames objectAtIndex:arc4random_uniform([possibleLastNames count])];
    
    float x = drand48();
    float number = 999999999999 * x;
    NSString* newNumber = [NSString stringWithFormat:@"+%12.0lf", number];
    self.number = newNumber;
    
    
    //self.lastName = lastname;
    //self.number = number;
    
    
    return self;
}



- (NSComparisonResult)compareByName:(SinglePerson*)otherObject
{
    NSComparisonResult result = [self.name compare:otherObject.name options:NSCaseInsensitiveSearch];
    if(result != NSOrderedSame)
        return result;
    else
        return [self compareByLastName:otherObject];
}


- (NSComparisonResult)compareByLastName:(SinglePerson*)otherObject
{
    return [self.lastName compare:otherObject.lastName options:NSCaseInsensitiveSearch];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@,%@,%@", self.name, self.lastName, self.number];
}


/*

- (NSData*)serialize
{
    NSMutableString* totalString = [[NSMutableString alloc]init];
    [totalString appendString:@"?"];
    [totalString appendString:self.name];
    [totalString appendString:@"!"];
    [totalString appendString:self.lastName];
    [totalString appendString:@"!"];
    [totalString appendString:self.number];
    
    return [totalString dataUsingEncoding:NSUTF8StringEncoding];
}

 */



- (BOOL)unserialize:(NSString*)src
{
    NSArray* strings = [src componentsSeparatedByString:@","];
    
    if([strings count] != 3)
        return NO;
    
    self.name = strings[0];
    self.lastName = strings[1];
    self.number = strings[2];

    return YES;
    
}

@end
