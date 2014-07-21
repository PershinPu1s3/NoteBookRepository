//
//  AddEditViewController.h
//  Notebook2
//
//  Created by Sergey on 7/14/14.
//  Copyright (c) 2014 sandbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinglePerson.h"

@interface AddEditViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic) NSInteger currentPersonIndex;

@property (strong, nonatomic) SinglePerson* currentPerson;

- (void)callEditWindow:(Boolean)isEdit withIndex:(NSInteger)personIndex;

- (void)callEditWindow:(Boolean)isEdit withIndexPath:(NSIndexPath*)currentPath;

@end
