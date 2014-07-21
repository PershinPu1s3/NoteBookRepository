//
//  ViewController.m
//  Notebook2
//
//  Created by Sergey on 7/14/14.
//  Copyright (c) 2014 sandbox. All rights reserved.
//

#import "ViewController.h"
#import "AddEditViewController.h"
#import "SinglePerson.h"

@interface ViewController()
{
    IBOutlet UITableView* contactsTable;
    IBOutlet UINavigationBar* contactsNavigationBar;
    IBOutlet UISearchBar* searchBar;
    NSArray* data;
    
    NSMutableArray* sectionHeaders;
    NSMutableArray* elementsNumberInEachHeader;
    
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Add"
    style:UIBarButtonItemStylePlain target:self action:@selector(AddContactPressed)];
    
    
    self.navigationItem.rightBarButtonItem = button;
    self.navigationItem.title = @"Contacts";
    
    data = [[ContactsModel model] getContactsByQuery:@""];
    
    sectionHeaders = [[NSMutableArray alloc]init];
    elementsNumberInEachHeader = [[NSMutableArray alloc]init];
    [self renewHeaders];
    
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.title = @"Contacts";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)renewHeaders
{
    [[ContactsModel model] sortBy:eName];
    
    [sectionHeaders removeAllObjects];
    [elementsNumberInEachHeader removeAllObjects];
    
    for(SinglePerson* current in data)
    {
        NSString* firstSymbol = [current.name substringToIndex:1];
        NSString* firstBigSymbol = [firstSymbol uppercaseString];
        
        if(!([sectionHeaders.lastObject isEqualToString:firstSymbol] || [sectionHeaders.lastObject isEqualToString:firstBigSymbol]))
        {
            [sectionHeaders addObject:firstBigSymbol];
            [elementsNumberInEachHeader addObject:[NSNumber numberWithInt:1]];
        }
        else
        {
            //only the way I found to increment last integer element
            //numberWithInt doesn't work
            
            NSNumber* currentCounter = [[NSNumber alloc] initWithInt:0];
            currentCounter = [elementsNumberInEachHeader lastObject];
            
            int currentIntCounter = [currentCounter intValue];
            currentIntCounter++;
            NSNumber* currentCounter2 = [[NSNumber alloc] initWithInt:currentIntCounter];
            
            [elementsNumberInEachHeader removeLastObject];
            [elementsNumberInEachHeader addObject:currentCounter2];
            
        }
    }
}


- (void)renewTableData
{
    [self renewHeaders];
    [contactsTable reloadData];
}

- (void)AddContactPressed
{
    NSUInteger elementIndex = [[[ContactsModel model].currentFetchController fetchedObjects]count];
    
    AddEditViewController* addEdit = [[AddEditViewController alloc] initWithNibName:nil bundle:nil];
    
    [addEdit callEditWindow:false withIndexPath:[NSIndexPath indexPathWithIndex:elementIndex]];
    [self.navigationController pushViewController:addEdit animated:YES];
}

//- (void)EditContactPressed
//{
    
    
//}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //new
    return [[[ContactsModel model].currentFetchController sections] count];
    
    //old
    //return sectionHeaders.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    //new
    id <NSFetchedResultsSectionInfo> sectionInfo = [[ContactsModel model].currentFetchController sections][section];
    return [sectionInfo numberOfObjects];

    //old
    //return [[elementsNumberInEachHeader objectAtIndex:section] integerValue];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //new
    id <NSFetchedResultsSectionInfo> sectionInfo = [[ContactsModel model].currentFetchController sections][section];
    return [sectionInfo name];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

//4
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    
    //CoreData version
    [self configureCellFromCoreData:cell atIndexPath:indexPath];
    return cell;
    
    
    
    
    
    //old version
    NSInteger currentIndex = 0;
    for(NSInteger i = 0; i < indexPath.section; i++)
    {
        currentIndex += [[elementsNumberInEachHeader objectAtIndex:i] integerValue];
    }
    currentIndex += indexPath.row;
    
    
    SinglePerson* current = [data objectAtIndex:currentIndex];
    NSMutableString* viewNameAndLastName = [[NSMutableString alloc]initWithString:(current.name)] ;
    [viewNameAndLastName appendString:@" "];
    [viewNameAndLastName appendString:(current.lastName)];
    
    NSString* viewNumber = [[NSString alloc]initWithString:(current.number)];
    
    [cell.textLabel setText: viewNameAndLastName];
    [cell.detailTextLabel setText: viewNumber];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AddEditViewController* addEdit = [[AddEditViewController alloc] initWithNibName:nil bundle:nil];
    
    //coreData way
    //NSManagedObject *object = [[ContactsModel model].currentFetchController objectAtIndexPath:indexPath];
    [addEdit callEditWindow:true withIndexPath:indexPath];
    
    
    
    //old way
    /*SinglePerson* current = [data objectAtIndex:indexPath.row];
    NSInteger currentIndex = 0;
    for(NSInteger i = 0; i < indexPath.section; i++)
    {
        currentIndex += [[elementsNumberInEachHeader objectAtIndex:i] integerValue];
    }
    currentIndex += indexPath.row;
    
    [addEdit callEditWindow:true withIndex:currentIndex];
     */
    
    
    
    [self.navigationController pushViewController:addEdit animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}






- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [searchBar resignFirstResponder];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    data = [[ContactsModel model] getContactsByQuery:searchText];
    
    //change fetch query and fetch controller in model(?)
    [[ContactsModel model] changeFetchRequest:searchText];
    
    
    
    [self renewTableData];
    //reload table by query
    
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [searchBar resignFirstResponder];
}


- (void)configureCellFromCoreData:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [[ContactsModel model].currentFetchController objectAtIndexPath:indexPath];
    
    NSMutableString* viewNameAndLastName = [[NSMutableString alloc]initWithString:[[object valueForKey:@"name"] description]] ;
    [viewNameAndLastName appendString:@" "];
    [viewNameAndLastName appendString:[[NSString alloc]initWithString:[[object valueForKey:@"lastName"] description]]];
    
    NSString* viewNumber = [[NSString alloc]initWithString:[[object valueForKey:@"phoneNumber"] description]];
    
    [cell.textLabel setText: viewNameAndLastName];
    [cell.detailTextLabel setText: viewNumber];
    
}


    //[[ContactsModel model] writeToFile:@"notebook.txt"];








@end
