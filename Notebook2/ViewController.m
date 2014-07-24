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
#import "NoteBookRepository.h"



@interface ViewController()
{
    IBOutlet UITableView* contactsTable;
    IBOutlet UINavigationBar* contactsNavigationBar;
    IBOutlet UISearchBar* searchBar;
    
    
    IBOutlet FBLoginView* facebookLoginView;
    //NSArray* data;
    
    //NSMutableArray* sectionHeaders;
    //NSMutableArray* elementsNumberInEachHeader;
    
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
    

    facebookLoginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"email", @"user_friends"] ];

    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)renewTableData
{
    [[ContactsModel model] refetch];
    [contactsTable reloadData];
}

- (void)AddContactPressed
{
    AddEditViewController* addEdit = [[AddEditViewController alloc] initWithNibName:nil bundle:nil];
    //[addEdit callEditWindow:false withIndexPath:nil];
    [addEdit callEditWindowWithPath:nil];
    
    [self.navigationController pushViewController:addEdit animated:YES];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //DIRECTACCESS
    return [[[ContactsModel model].currentFetchController sections] count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //DIRECTACCESS
    id <NSFetchedResultsSectionInfo> sectionInfo = [[ContactsModel model].currentFetchController sections][section];
    return [sectionInfo numberOfObjects];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //DIRECTACCESS
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
    
    NoteBookRepository* object = [[ContactsModel model].currentFetchController objectAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    for (UIView* view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    
    UIView* view = cell.contentView;
    [view setNeedsDisplay];
    
    NSMutableString* viewNameAndLastName = [[NSMutableString alloc]initWithString:[object.name description]] ;
    [viewNameAndLastName appendString:@" "];
    [viewNameAndLastName appendString:[[NSString alloc]initWithString:[object.lastName  description]]];
    NSString* viewNumber = [[NSString alloc]initWithString:[object.phoneNumber description]];
    
    
    [cell.textLabel setText: viewNameAndLastName];
    [cell.detailTextLabel setText: viewNumber];
    CGRect lFrame = CGRectMake(cell.frame.size.width - 20, 0, 20, cell.frame.size.height);
    UILabel* sourceLabel = [[UILabel alloc] initWithFrame:lFrame];
    [sourceLabel setText:object.source];
    [view addSubview:sourceLabel];

    return cell;
  
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AddEditViewController* addEdit = [[AddEditViewController alloc] initWithNibName:nil bundle:nil];
    
    //[addEdit callEditWindow:true withIndexPath:indexPath];

    
    [addEdit callEditWindowWithPath:indexPath];
    
    [self.navigationController pushViewController:addEdit animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}






- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [searchBar resignFirstResponder];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

    [[ContactsModel model] renewFetchControllerBySearchQuery:searchText];
    [self renewTableData];
    
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [searchBar resignFirstResponder];
}





- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{

}


- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{

}
 



- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    [[ContactsModel model] getContactsFromFacebookForUser];
    
}








@end
