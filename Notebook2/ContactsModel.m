//
//  ContactsModel.m
//  Notebook2
//
//  Created by Sergey on 7/14/14.
//  Copyright (c) 2014 sandbox. All rights reserved.
//

#import "ContactsModel.h"
#import <AddressBook/AddressBook.h>





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
        
        
        
        [sharedContactsModelInstance_ renewFetchControllerBySearchQuery:@""];
        [sharedContactsModelInstance_ refetch];
        
        if([[sharedContactsModelInstance_.currentFetchController fetchedObjects]count] == 0)
        {
            [sharedContactsModelInstance_ initDefaultDictionaryWithSize:10];
        }
        

        //[sharedContactsModelInstance_.currentFetchController performFetch:nil];
        
        
        [sharedContactsModelInstance_ getContactsFromPhone ];
        
        
        [sharedContactsModelInstance_ renewFetchControllerBySearchQuery:@""];
        [sharedContactsModelInstance_ refetch];
        
        //facebook
        
        
        

        
        
        
        //[sharedContactsModelInstance_ getContactsFromFacebookForUser:nil];

        
        
      
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






- (void)getContactsFromPhone
{
    //long shee(i)t
    
    
    
    //first we have to ask permission
    //but I have no stable code for it
    //

    
    //get contacts from iPhone contact book
    
    
    CFErrorRef error;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
        {
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You have denied access to relevant iPhone contacts. Cached contacts will be displayed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }

    
    //get all existing phone contacts from CoreData
    [self.currentFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"source like %@", @"p"]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[sortDescriptor];
    [self.currentFetchRequest setSortDescriptors:sortDescriptors];
    self.currentFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.currentFetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"section" cacheName:nil];
    [self refetch];
    NSArray* cachedPhoneContacts = [self.currentFetchController fetchedObjects];
    //set marks on CoreData contacts
    NSInteger phoneContactsCapacity = [cachedPhoneContacts count];
    NSMutableArray* coreDataPhoneContactsTrashMarks = [[NSMutableArray alloc] initWithCapacity:phoneContactsCapacity];
    for(int i=0; i < phoneContactsCapacity; i++)
    {
        coreDataPhoneContactsTrashMarks[i] = [NSNumber numberWithBool:YES];
    }
    
    
    
    
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    if(numberOfPeople < 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot refresh iPhone contacts. Cached contacts have been loaded(if there are any)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];

        return;
    }
    
    
    //synchronize two phone contacts buffers:
    //if iPhone contact is missing in CoreData -> add it to CoreData
    //if CoreData contact is missing in iPhone -> mark it, it's an irrelevant contact
    for(int i=0; i < numberOfPeople; i++)
    {
        
        NSString* phoneContactName;
        NSString* phoneContactLastName;
        NSString* phoneContactPhoneNumber;
        
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        phoneContactName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        phoneContactLastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        phoneContactPhoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        
        BOOL phoneContactExistsInCoreData = NO;
        
        for(int i=0; i < phoneContactsCapacity; i++)
        {
            NoteBookRepository* currentCoreDataContact = cachedPhoneContacts[i];
            if([currentCoreDataContact.name isEqualToString:phoneContactName ]&& [currentCoreDataContact.lastName isEqualToString:phoneContactLastName ]&& [currentCoreDataContact.phoneNumber isEqualToString:phoneContactPhoneNumber])
            {
                phoneContactExistsInCoreData = YES;     //no need to add from iPhone to CoreData
                coreDataPhoneContactsTrashMarks[i] = @NO;
                break;
            }
            
        }
        
        if(!phoneContactExistsInCoreData)
        {
            //add contact
            NoteBookRepository* newPerson = [[NoteBookRepository alloc]initWithEntity:self.entity insertIntoManagedObjectContext:self.managedObjectContext];
            newPerson.name = phoneContactName ? phoneContactName : @"";
            newPerson.lastName = phoneContactLastName ? phoneContactLastName : @"";
            newPerson.phoneNumber = phoneContactPhoneNumber ?  phoneContactPhoneNumber : @"";
            
            
            unichar firstLetter = [newPerson.name characterAtIndex:0];
            NSString* sectionName = [[[NSString alloc]initWithFormat:@"%c",firstLetter] uppercaseString];
            newPerson.section = sectionName;
            newPerson.source = @"p";
            
        }
    }
    
    //delete all the marked contacts from context
    
    for(int i = 0; i < phoneContactsCapacity; i++)
    {
        if([coreDataPhoneContactsTrashMarks[i]  isEqual: @YES])
        {
            NoteBookRepository* deadObject = cachedPhoneContacts[i];
            [self.managedObjectContext deleteObject:deadObject];
        }
    }
    
    [self.managedObjectContext save:nil];
    
    
    [self renewFetchControllerBySearchQuery:@""];
    [self refetch];
    
    //now we have all people from iPhone
}




- (void)getContactsFromFacebookForUser
{

    
    FBSessionState currentState = FBSession.activeSession.state;
    
    
    if (FBSession.activeSession.isOpen)
    {
        
        [FBRequestConnection startWithGraphPath:@"/me/taggable_friends"
                                     parameters:nil
                                     HTTPMethod:@"GET"
                              completionHandler:^(
                                                  FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error
                                                  )
        {
            if(error)
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot refresh facebook contacts. Cached contacts have been loaded(if there are any)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            else
            {
                //long and hard syncronization, like iPhone contacts one
                
                
                [self.currentFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"source like %@", @"f"]];
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                NSArray *sortDescriptors = @[sortDescriptor];
                [self.currentFetchRequest setSortDescriptors:sortDescriptors];
                self.currentFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.currentFetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"section" cacheName:nil];
                [self refetch];
                NSArray* cachedPhoneContacts = [self.currentFetchController fetchedObjects];
                
                
                //set marks on CoreData contacts
                NSInteger phoneContactsCapacity = [cachedPhoneContacts count];
                NSMutableArray* coreDataPhoneContactsTrashMarks = [[NSMutableArray alloc] initWithCapacity:phoneContactsCapacity];
                for(int i=0; i < phoneContactsCapacity; i++)
                {
                    coreDataPhoneContactsTrashMarks[i] = [NSNumber numberWithBool:YES];
                }
                
                
                
                
                
                NSArray* facebookContacts = (NSArray*)[result data];
                

                
                for(id<FBGraphUser> currentFacebookFriend in facebookContacts)
                {
                    
                    NSString* facebookContactName;
                    NSString* facebookContactLastName;
                    
                    NSArray* facebookData = [currentFacebookFriend.name componentsSeparatedByString:@" "];
                    
                    facebookContactName = [facebookData firstObject];
                    facebookContactLastName = [facebookData lastObject];
                   
                    
                    BOOL facebookContactExistsInCoreData = NO;
                    
                    for(int i=0; i < phoneContactsCapacity; i++)
                    {
                        NoteBookRepository* currentCoreDataContact = cachedPhoneContacts[i];
                        if([currentCoreDataContact.name isEqualToString:facebookContactName ]&& [currentCoreDataContact.lastName isEqualToString:facebookContactLastName ])
                        {
                            facebookContactExistsInCoreData = YES;     //no need to add from iPhone to CoreData
                            coreDataPhoneContactsTrashMarks[i] = @NO;
                            break;
                        }
                        
                    }
                    
                    if(!facebookContactExistsInCoreData)
                    {
                        //add contact
                        NoteBookRepository* newPerson = [[NoteBookRepository alloc]initWithEntity:self.entity insertIntoManagedObjectContext:self.managedObjectContext];
                        newPerson.name = facebookContactName;
                        newPerson.lastName = facebookContactLastName;
                        newPerson.phoneNumber = @"";
                        
                        unichar firstLetter = [newPerson.name characterAtIndex:0];
                        NSString* sectionName = [[[NSString alloc]initWithFormat:@"%c",firstLetter] uppercaseString];
                        newPerson.section = sectionName;
                        newPerson.source = @"f";
                        
                    }
                }
                
                //delete all the marked contacts from context
                
                for(int i = 0; i < phoneContactsCapacity; i++)
                {
                    if([coreDataPhoneContactsTrashMarks[i]  isEqual: @YES])
                    {
                        NoteBookRepository* deadObject = cachedPhoneContacts[i];
                        [self.managedObjectContext deleteObject:deadObject];
                    }
                }
                
                [self.managedObjectContext save:nil];

                [self renewFetchControllerBySearchQuery:@""];
                [self refetch];
                
                
                //and now we have all people from facebook
                
            }
            
        }];
        
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Facebook session hasn't been created. Cached contacts have been loaded(if there are any)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }

    
}



- (NoteBookRepository*)getObjectAtIndexPath:(NSIndexPath*)path
{
    return [self.currentFetchController objectAtIndexPath:path];
}


- (BOOL) addPersonName:(NSString*)name withLastName:(NSString*)lastName andPhoneNumber:(NSString*)number
{
    //add from application
    
    
    NoteBookRepository* newObject = [[NoteBookRepository alloc] initWithEntity:self.entity insertIntoManagedObjectContext:self.managedObjectContext];
    newObject.name = name;
    newObject.lastName = lastName;
    newObject.phoneNumber = number;
    
    unichar firstLetter = [name characterAtIndex:0];
    NSString* sectionName = [[[NSString alloc]initWithFormat:@"%c",firstLetter] uppercaseString];
    newObject.section = sectionName;
    
    
    
    newObject.source = @"a";
    
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



-(void) renewFetchControllerByPredicate:(NSPredicate*)predicate
{
   
    [self.currentFetchRequest setPredicate:predicate];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[sortDescriptor];
    [self.currentFetchRequest setSortDescriptors:sortDescriptors];
    
    self.currentFetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.currentFetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"section" cacheName:nil];
}




-(void) renewFetchControllerBySearchQuery:(NSString*)query
{
    NSPredicate* currentPredicate;// = [[NSPredicate alloc]init];
    
    if([query isEqualToString:@""])
        currentPredicate = [NSPredicate predicateWithValue:YES];
    else
        currentPredicate = [NSPredicate predicateWithFormat:@"name beginswith [cd]%@ OR lastName beginswith [cd]%@ OR phoneNumber beginswith [cd]%@", query, query, query ];
    
    [self renewFetchControllerByPredicate:currentPredicate];
    
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
    
    //else we have no power for facebook or iPhone format

    
    return result;
}




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




@end
