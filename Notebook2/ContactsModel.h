//
//  ContactsModel.h
//  Notebook2
//
//  Created by Sergey on 7/14/14.
//  Copyright (c) 2014 sandbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SinglePerson.h"



typedef enum {eName, eLastName} SortingOption;





@interface ContactsModel : NSObject<NSFetchedResultsControllerDelegate>

//@property (weak, nonatomic) UIViewController* viewController;

@property (strong, nonatomic) NSMutableArray* contactsBuffer;

@property (strong, nonatomic) NSString* contactsFileName;




+ (ContactsModel*)model;

- (void)initDefaultDictionaryWithSize:(NSInteger)size;

- (void)addNewContact:(SinglePerson*) ewContact;

- (void)editContactByIndex:(NSUInteger)indexPath withNewContact:(SinglePerson*) contact;

- (void)deleteContactByIndex:(NSUInteger)indexPath;

- (void)sortBy:(SortingOption)option;

- (NSArray*)getContactsByQuery:(NSString*)query;

- (BOOL)readFromFile:(NSString*)fileName;

- (BOOL) writeToFile:(NSString*)fileName;

- (BOOL)writeToFile;

- (BOOL)readFromFile;

+ (NSString*)validatePersonData:(SinglePerson*)testPerson;








///////////////////////////NEW MODEL SANDBOX/////////////////


@property ( strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property ( strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property ( strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@property (strong, nonatomic) NSFetchRequest* currentFetchRequest;


@property (strong, nonatomic) NSFetchedResultsController* currentFetchController;





- (void) changeFetchRequest:(NSString*)query;



///////////////////////////NEW MODEL////////////////////////

@end
