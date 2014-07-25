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
#import "NoteBookRepository.h"
#import <FacebookSDK/FacebookSDK.h>



typedef enum {eName, eLastName} SortingOption;





@interface ContactsModel : NSObject<NSFetchedResultsControllerDelegate>//, FBSessionDelegate>



+ (ContactsModel*)model;


+ (NSString*)validatePersonName:(NSString*)name lastName:(NSString*)lastName phoneNumber:(NSString*)number;




///////////////////////////NEW MODEL SANDBOX/////////////////


@property ( strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property ( strong, nonatomic) NSManagedObjectModel* managedObjectModel;
@property ( strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (strong, nonatomic) NSEntityDescription* entity;


@property (strong, nonatomic) NSFetchRequest* currentFetchRequest;
@property (strong, nonatomic) NSFetchedResultsController* currentFetchController;



- (void)renewFetchControllerBySearchQuery:(NSString*)query;

- (void)renewFetchControllerByPredicate:(NSPredicate*)predicate;

- (BOOL)addPersonName:(NSString*)name withLastName:(NSString*)lastName andPhoneNumber:(NSString*)number;

- (BOOL)editPersonName:(NSString*)name withLastName:(NSString*)lastName andPhoneNumber:(NSString*)number atFetchIndexPath:(NSIndexPath*)path;

- (BOOL)deletePersonAtIndexPath:(NSIndexPath*)path;

- (NoteBookRepository*)getObjectAtIndexPath:(NSIndexPath*)path;

- (void)refetch;

//after changing request, adding, editing, or deleting

//- (void) resetHeaders;
//will be in refetch...or not, if doesn't needed

- (void)initDefaultDictionaryWithSize:(NSInteger)size;

- (void)getContactsFromPhone;

- (void)getContactsFromFacebookForUser;



///////////////////////////NEW MODEL////////////////////////

@end
