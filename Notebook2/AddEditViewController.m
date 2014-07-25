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
    
    IBOutlet UIButton* shareButton;
    IBOutlet UIButton* callButton;
    IBOutlet UIButton* deleteButton;
    
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
    

    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    namefield.delegate = self;
    lastNameField.delegate = self;
    numberField.delegate = self;
    
    
    
    
    deleteButton.frame = CGRectMake(shareButton.frame.origin.x + shareButton.frame.origin.x - callButton.frame.origin.x,
                                    shareButton.frame.origin.y,
                                    shareButton.frame.size.width,
                                    shareButton.frame.size.height);
    
    
    [shareButton addTarget:self action:@selector(sharePressed) forControlEvents:UIControlEventTouchUpInside];
    [callButton addTarget:self action:@selector(callPressed) forControlEvents:UIControlEventTouchUpInside];
    
}



- (void)sharePressed
{
    
    if (![MFMailComposeViewController canSendMail])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"email error" message:@"Sorry, an app now cannot send an email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
    
        MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc]init];
        mailController.mailComposeDelegate = self;
    
        
        [mailController setSubject:@"Contact sending"];
        
        
        NSMutableArray *vcfArray = [[NSMutableArray alloc] init];
        
        [vcfArray addObject:@"BEGIN:VCARD"];
        [vcfArray addObject:@"VERSION:3.0"];
        
        [vcfArray addObject:[NSString stringWithFormat:@"FN:%@ %@", namefield.text, lastNameField.text]];
        
        [vcfArray addObject:[NSString stringWithFormat:@"N:%@;%@",namefield.text, lastNameField.text]];
        
        if (![numberField.text isEqualToString:@""])
                [vcfArray addObject:[NSString stringWithFormat:@"TEL:%@", numberField.text]];
        
        [vcfArray addObject:@"END:VCARD"];
        
        NSString* vcfStr = [vcfArray componentsJoinedByString:@"\n"];
        NSData* vcfData = [vcfStr dataUsingEncoding:NSUTF8StringEncoding];
        
        [mailController addAttachmentData:vcfData mimeType:@"text/vcard" fileName:lastNameField.text];
        
    
        [self presentViewController:mailController animated:YES completion:NULL];
    }
  
    
}



- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //hj
    
    switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			//???
			break;
		case MFMailComposeResultSent:
			//
			break;
		case MFMailComposeResultFailed:
			//???
			break;
		default:
			//???
			break;
	}

    
    
    
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    //[self presentViewController: animated:YES completion:NULL];
	
}




- (void)callPressed
{
    //make default URL call
    
    NSURL *phoneNumber = [[NSURL alloc] initWithString: [[NSString alloc]initWithFormat:@"tel:%@" , numberField.text ] ];
    
    if([[UIApplication sharedApplication] canOpenURL:phoneNumber])
        [[UIApplication sharedApplication] openURL: phoneNumber];
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"URL error" message:@"Sorry, an app now cannot make a call" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];

    }
    
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
        
        deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [deleteButton addTarget:self
                         action:@selector(deletePressed)
               forControlEvents:UIControlEventTouchUpInside];
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];


        
        [self.view addSubview:deleteButton];
         
        
        
        NoteBookRepository *object = [[ContactsModel model] getObjectAtIndexPath:currentPath];
        
        [namefield setText:object.name];
        [lastNameField setText:object.lastName];
        [numberField setText:object.phoneNumber];
        //edit
    }
}






@end
