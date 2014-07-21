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
    
    
    // Do any additional setup after loading the view from its nib.
}


- (void)backgroundPressed
{
    [self.view endEditing:YES];
}


- (void)donePressed
{
    
    
    self.currentPerson.name = namefield.text;
    self.currentPerson.lastName = lastNameField.text;
    self.currentPerson.number = numberField.text;
    
    
    //VALIDITY CHECK

    
    NSString* error = [ContactsModel validatePersonData:self.currentPerson];
    
    if(![error isEqualToString:@""])
    {
        UIAlertView *helloWorldAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [helloWorldAlert show];
    }
    /*
    if([self.currentPerson.name rangeOfString:@"[^A-Za-z .]" options:NSRegularExpressionSearch].location != NSNotFound)
    {
        UIAlertView *helloWorldAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"BAD NAME" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [helloWorldAlert show];
    }
    else if([self.currentPerson.lastName rangeOfString:@"[^A-Za-z .]" options:NSRegularExpressionSearch].location != NSNotFound)
    {
        UIAlertView *helloWorldAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"BAD LAST NAME" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [helloWorldAlert show];
    }
    //([0-9])\{12\}
    else if([self.currentPerson.number rangeOfString:@"[+]([0-9])\{12\}" options:NSRegularExpressionSearch].location == NSNotFound || self.currentPerson.number.length > 13)
    {
        UIAlertView *helloWorldAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"BAD PHONE NUMBER" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [helloWorldAlert show];
    }
    else
        valid = YES;
    */

    else
    {
        [[ContactsModel model] editContactByIndex:self.currentPersonIndex withNewContact:self.currentPerson];
        
        [[ContactsModel model] sortBy:eName];
        //[[ContactsModel model] sortBy:eLastName];
        
        id tableviewerId = [self.navigationController.childViewControllers firstObject ];
        ViewController* tableController = (ViewController*)tableviewerId;
        [tableController  renewTableData];
        
        [self backPressed];
    }

}




- (void)deletePressed
{
    [[ContactsModel model] deleteContactByIndex:self.currentPersonIndex];
    
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



//Core Data verison
- (void)callEditWindow:(Boolean)isEdit withIndexPath:(NSIndexPath*)currentPath
{
    if(!isEdit)
    {
        self.navigationItem.title = @"Add";
        

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
        
        NSManagedObject *object = [[ContactsModel model].currentFetchController objectAtIndexPath:currentPath];
        
        [namefield setText:[object valueForKey:@"name"]];
        [lastNameField setText:[object valueForKey:@"lastName"]];
        [numberField setText:[object valueForKey:@"phoneNumber"]];
        
        
        
    }
}




//old version
- (void)callEditWindow:(Boolean)isEdit withIndex:(NSInteger)personIndex;
{
    
    
    if(!isEdit)
    {
        self.navigationItem.title = @"Add";
        self.currentPerson = [SinglePerson alloc];
        self.currentPersonIndex =  [[ContactsModel model].contactsBuffer count];
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
        
        self.currentPersonIndex = personIndex;
        self.currentPerson = [[ContactsModel model].contactsBuffer objectAtIndex:personIndex];
        
        
        [namefield setText:(self.currentPerson.name)];
        [lastNameField setText:(self.currentPerson.lastName)];
        [numberField setText:(self.currentPerson.number)];
        
        
        
    }
}

@end
