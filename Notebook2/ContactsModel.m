//
//  ContactsModel.m
//  Notebook2
//
//  Created by Sergey on 7/14/14.
//  Copyright (c) 2014 sandbox. All rights reserved.
//

#import "ContactsModel.h"


static ContactsModel* sharedContactsModelInstance_ = nil;

@interface ContactsModel()
{
    
}
@end

@implementation ContactsModel

+ (ContactsModel*)model
{
    if (sharedContactsModelInstance_ == nil)
    {
        sharedContactsModelInstance_ = [[self alloc] init];
        [sharedContactsModelInstance_ initDefaultDictionaryWithSize:20];
    }
    return sharedContactsModelInstance_;
}


- (void)initDefaultDictionaryWithSize:(NSInteger)size;
{
    self.contactsBuffer = [[NSMutableArray alloc] init];
    
    BOOL reading = [self readFromFile:@"notebook.txt"];
    
    if(!reading)
    {
        for(int i=0; i < size; i++)
            [self.contactsBuffer addObject: [[SinglePerson alloc]randomPerson]];
    }
    
    [self sortBy:eName];

    
    
}

- (void)addNewContact:(SinglePerson*)newContact
{
    [self.contactsBuffer addObject:newContact];
    
   // UIAlertView *helloWorldAlert = [[UIAlertView alloc]
     //                               initWithTitle:@"Hello from model" message:@"GOT ADD REQUEST" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Display the Hello World Message
    //[helloWorldAlert show];
}


- (void)editContactByIndex:(NSUInteger)indexPath withNewContact:(SinglePerson*) contact;
{
    if(indexPath < self.contactsBuffer.count)
        [self deleteContactByIndex:indexPath];
    [self.contactsBuffer insertObject:contact atIndex:indexPath];
    
    //UIAlertView *helloWorldAlert = [[UIAlertView alloc]
         //                           initWithTitle:@"Hello from model" message:@"GOT EDIT REQUEST" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Display the Hello World Message
    //[helloWorldAlert show];
}


- (void)deleteContactByIndex:(NSUInteger)indexPath
{
    [self.contactsBuffer removeObjectAtIndex:indexPath];
}



- (void)sortBy:(SortingOption)option
{
    NSArray* sortedArray;
    if(option == eName)
    {
        sortedArray = [self.contactsBuffer sortedArrayUsingSelector:@selector(compareByName:)] ;
    }
    else
    {
        sortedArray = [self.contactsBuffer sortedArrayUsingSelector:@selector(compareByLastName:)] ;
    }
    [self.contactsBuffer setArray:sortedArray ];
}



- (NSArray*)getContactsByQuery:(NSString*)query;
{
    if([query isEqualToString:@""])
        return self.contactsBuffer;
    

    //NSString* predicateString = [[NSString alloc]initWithFormat:@"self.name beginswith [cd]%@ OR self.lastName beginswith [cd]%@", query, query ];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name beginswith [cd]%@ OR self.lastName beginswith [cd]%@", query, query ];
    //NSArray *filtered = [self.contactsBuffer subarrayWithRange:NSMakeRange(0, 5)];
    NSArray *filtered = [self.contactsBuffer filteredArrayUsingPredicate:predicate];
    
    
    return filtered;

}



+ (NSString*)validatePersonData:(SinglePerson*)testPerson;
{
    NSMutableString* result = [[NSMutableString alloc]initWithString:@""];
    
    
    if([testPerson.name rangeOfString:@"[^A-Za-z .]" options:NSRegularExpressionSearch].location != NSNotFound)
    {
        [result appendString:@" Bad name"];
    }
    if([testPerson.lastName rangeOfString:@"[^A-Za-z .]" options:NSRegularExpressionSearch].location != NSNotFound)
    {
        [result appendString:@" Bad last name"];
    }
    //([0-9])\{12\}
    if([testPerson.number rangeOfString:@"[+]([0-9])\{12\}" options:NSRegularExpressionSearch].location == NSNotFound || testPerson.number.length > 13)
    {
        [result appendString:@" Bad phone number"];
    }
    
    return result;
}



-(BOOL)readFromFile:(NSString*)fileName
{
    
    NSFileHandle *file;
    
    NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fullFilePath = [cachesFolder stringByAppendingPathComponent:fileName];
    
    [self.contactsBuffer removeAllObjects];
    
    if (!(file = [NSFileHandle fileHandleForReadingAtPath:fullFilePath]))
        return NO;
    
    NSData* databuffer = [[NSData alloc] initWithContentsOfFile:fullFilePath];
    if(!databuffer)
        return NO;
    
    
    NSArray* stringsBuffer = [[[NSString alloc] initWithData:databuffer encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"!"];
    for(NSString* current in stringsBuffer)
    {
        SinglePerson* p = [[SinglePerson alloc]init];
        if([p unserialize:current])
            [self.contactsBuffer addObject:p];
    }
    
    
    return YES;
}


-(BOOL) writeToFile:(NSString*)fileName
{
    //NSFileManager* manager = [[NSFileManager alloc]init];
    
    //if(![manager fileExistsAtPath:fileName])
    //{
    
    NSError* err;
    
    NSString* totalString;
    
    NSString *cachesFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fullFilePath = [cachesFolder stringByAppendingPathComponent:fileName];
    

    totalString = [self.contactsBuffer componentsJoinedByString:@"!"];
    
    //bool res = [dataTest writeToFile:file options:NSDataWritingAtomic error:&err];

    
    
   // BOOL ok = [str writeToFile:myFile atomically:YES encoding:NSUnicodeStringEncoding error:&err];
    
    
     //BOOL result =  [manager createFileAtPath:myFile contents:nil attributes:nil];&err
    //manager
    //}
    //return res;
    return [totalString writeToFile:fullFilePath atomically:YES encoding:NSUTF8StringEncoding error:&err];
}
    
    
    
    
    


@end
