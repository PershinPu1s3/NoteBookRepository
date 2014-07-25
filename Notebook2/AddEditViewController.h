//
//  AddEditViewController.h
//  Notebook2
//
//  Created by Sergey on 7/14/14.
//  Copyright (c) 2014 sandbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinglePerson.h"

#import <MessageUI/MessageUI.h>

@interface AddEditViewController : UIViewController<UITextFieldDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSIndexPath* currentPersonIndexPath;

- (void)callEditWindowWithPath:(NSIndexPath*)currentPath;


@end
