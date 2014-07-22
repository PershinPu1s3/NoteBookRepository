//
//  AddEditViewController.m
//  Notebook2
//
//  Created by Sergey on 7/14/14.
//  Copyright (c) 2014 sandbox. All rights reserved.
//

#import "AddEditViewController.h"
#import "ContactsModel.h"
#import "ViewController.h"


@interface AddEditViewController ()
{
    IBOutlet UITextField* namefield;
    IBOutlet UITextField* lastNameField;
    IBOutlet UITextField* numberField;
    IBOutlet UIButton* backgroundButton;
    
    //BOOL isEditMode;
}

@end

@implementation AddEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    [backgroundButton addTarget:(self) action:@selector(backgroundPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                               style:UIBarButtonItemStylePlain target:self action:@selector(donePressed) ];
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                               style:UIBarButtonItemStylePlain target:self action:@selector(backPressed) ];
    
    namefield.delegate = self;
    lastNameField.delegate = self;
    numberField.delegate = self;
    
    
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = backButton;
}


- (void)backgroundPressed
{
    [self.view endEditing:YES];
}


- (void)donePressed
{
    NSString* errorText;
    if(![errorText = [ContactsModel validatePersonName:namefield.text lastName:lastNameField.text phoneNumber:numberField.text] isEqualToString:@""])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Wrong format" message:errorText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if(!self.currentPersonIndexPath)
    {
        [[ContactsModel model] addPersonName:namefield.text withLastName:lastNameField.text andPhoneNumber:numberField.text];
    }
    else
    {
        [[ContactsModel model] editPersonName:namefield.text withLastName:lastNameField.text andPhoneNumber:numberField.text atFetchIndexPath:self.currentPersonIndexPath];
    }
    
    id tableviewerId = [self.navigationController.childViewControllers firstObject ];
    ViewController* tableController = (ViewController*)tableviewerId;
    [tableController  renewTableData];
        
    [self backPressed];

}




- (void)deletePressed
{
    [[ContactsModel model] deletePersonAtIndexPath:self.currentPersonIndexPath];
    
    id tableviewerId = [self.navigationController.childViewControllers firstObject ];
    ViewController* tableController = (ViewController*)tableviewerId;
    [tableController  renewTableData];
    
    [self backPressed];
}


- (void)backPressed
{
    [self.navigationController popViewControllerAnimated:YES ];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}


- (void)callEditWindowWithPath:(NSIndexPath*)currentPath
{
    self.currentPersonIndexPath = currentPath;
    if(!currentPath)
    {
        self.navigationItem.title = @"Add";
        //add
    }
    else
    {
        self.navigationItem.title = @"Edit";
        
        UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [deleteButton addTarget:self
                         action:@selector(deletePressed)
               forControlEvents:UIControlEventTouchUpInside];
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        deleteButton.frame = CGRectMake(200.0, 250.0, 160.0, 40.0);
        [self.view addSubview:deleteButton];
        
        NoteBookRepository *object = [[ContactsModel model] getObjectAtIndexPath:currentPath];
        
        [namefield setText:object.name];
        [lastNameField setText:object.lastName];
        [numberField setText:object.phoneNumber];
        //edit
    }
}






@end
