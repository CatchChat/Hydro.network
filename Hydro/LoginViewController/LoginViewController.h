//
//  LoginViewController.h
//  Hydro
//
//  Created by kevinzhow on 14/12/25.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HydroHelper.h"
#import <SAMTextField.h>

@interface LoginViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet SAMTextField *emailtextfield;
@property (weak, nonatomic) IBOutlet SAMTextField *passwordField;

- (IBAction)doClickLoginButton:(id)sender;

@end
