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
        sharedContactsModelInstance_ = [[ContactsModel alloc]init];
        
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NotebookModel" withExtension:@"momd"];
        sharedContactsModelInstance_.managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] initWithContentsOfURL:modelURL];
        
        NSError *error = nil;
        sharedContactsModelInstance_.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:
                                                                   sharedContactsModelInstance_.managedObjectModel];
        NSURL* applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"NotebookData.sqlite"];
        if (![sharedContactsModelInstance_.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:
              storeURL options:nil error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        sharedContactsModelInstance_.managedObjectContext = [[NSManagedObjectContext alloc] init];
        [sharedContactsModelInstance_.managedObjectContext setPersistentStoreCoordinator:sharedContactsModelInstance_.persistentStoreCoordinator];
        
        sharedContactsModelInstance_.entity = [NSEntityDescription entityForName:@"PhoneBookEntity" inManagedObjectContext:sharedContactsModelInstance_.managedObjectContext];
        
        sharedContactsModelInstance_.currentFetchRequest = [[NSFetchRequest alloc] init];
        [sharedContactsModelInstance_.currentFetchRequest setEntity:sharedContactsModelInstance_.entity];
        [sharedContactsModelInstance_.currentFetchRequest setFetchBatchSize:20];
        
        
        [sharedContactsModelInstance_ renewFetchControllerByQuery:@""];
        [sharedContactsModelInstance_ refetch];
        
        if([[sharedContactsModelInstance_.currentFetchController fetchedObjects]count] == 0)
        {
            [sharedContactsModelInstance_ initDefaultDictionaryWithSize:20];
        }
        

        [sharedContactsModelInstance_.currentFetchController performFetch:nil];
      
    }
    return sharedContactsModelInstance_;
}




- (void)initDefaultDictionaryWithSize:(NSInteger)size;
{
    for(int i=0; i < size; i++)
    {
        SinglePerson* newPerson = [[SinglePerson alloc]randomPerson];
        [self addPersonName:newPerson.name withLastName:newPerson.lastName andPhoneNumber:newPerson.number];
    }
}


- (NoteBookRepository*)getObjectAtIndexPath:(NSIndexPath*)path
{
    return [self.currentFetchController objectAtIndexPath:path];
}


- (BOOL) addPersonName:(NSString*)name withLastName:(NSString*)lastName andPhoneNumber:(NSString*)number
{
    //validity check should be done by ManagedObject itself. But how?
    
    
    NoteBookRepository* newObject = [[NoteBookRepository alloc] initWithEntity:self.entity insertIntoManagedObjectContext:self.managedObjectContext];
    newObject.name = name;
    newObject.lastName = lastName;
    newObject.phoneNumber = number;
    
    unichar firstLetter = [name characterAtIndex:0];
    NSString* sectionName = [[[NSString alloc]initWithFormat:@"%c",firstLetter] uppercaseString];
    newObject.section = sectionName;
    
    [self.managedObjectContext save:nil];
    
    return YES;
}

- (BOOL) deletePersonAtIndexPath:(NSIndexPath*)path
{
    NoteBookRepository* newObject = [self getObjectAtIndexPath:path];
    [self.managedObjectContext deleteObject:newObject];
    
    [self.managedObjectContext save:nil];
    return YES;
}



-(void) renewFetchControllerByQuery:(NSString*)query
{
    if([query isEqualToString:@""])
        [self.currentFetchRequest setPredicate:[NSPredicate predicateWithValue:YES]];
    else
        [self.currentFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name beginswith [cd]%@ OR lastName beginswith [cd]%@ OR phoneNumber beginswith [cd]%@", query, query ]];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[sortDescriptor];
    [self.currentFetchRequest setSortDescriptors:sortDescriptors];
    
    self.currentFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.currentFetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"section" cacheName:nil];
    
    
    
    
}



- (void) refetch
{

    [self.currentFetchController performFetch:nil];
}



+ (NSString*)validatePersonName:(NSString*)name lastName:(NSString*)lastName phoneNumber:(NSString*)number
{
    NSMutableString* result = [[NSMutableString alloc]initWithString:@""];
    
    
    if([name rangeOfString:@"[^A-Za-z .]" options:NSRegularExpressionSearch].location != NSNotFound)
    {
        [result appendString:@" Bad name"];
    }
    if([lastName rangeOfString:@"[^A-Za-z .]" options:NSRegularExpressionSearch].location != NSNotFound)
    {
        [result appendString:@" Bad last name"];
    }
    //rude
    if([number rangeOfString:@"[+]([0-9])\{12\}" options:NSRegularExpressionSearch].location == NSNotFound || number.length > 13)
    {
        [result appendString:@" Bad phone number"];
    }
    
    return result;
}



    




    
//never called
/*- (void) resetHeaders
{
    [self.currentFetchController performFetch:nil];
    NSArray* allObjects = [self.currentFetchController fetchedObjects];
    for(NSManagedObject* current in allObjects)
    {
        unichar firstLetter = [[current valueForKey:@"name"] characterAtIndex:0];
        NSString* sectionName = [[[NSString alloc]initWithFormat:@"%c",firstLetter] uppercaseString];
        [current setValue:sectionName forKey:@"section"];
    }
}*/






- (BOOL) editPersonName:(NSString*)name withLastName:(NSString*)lastName andPhoneNumber:(NSString*)number atFetchIndexPath:(NSIndexPath*)path
{
    NoteBookRepository* newObject = [self getObjectAtIndexPath:path];
    
    newObject.name = name;
    newObject.lastName = lastName;
    newObject.phoneNumber = number;
    
    unichar firstLetter = [name characterAtIndex:0];
    NSString* sectionName = [[[NSString alloc]initWithFormat:@"%c",firstLetter] uppercaseString];
    newObject.section = sectionName;
    
    [self.managedObjectContext save:nil];
    
    return YES;
}




//after changing request, adding, editing, or deleting




@end
