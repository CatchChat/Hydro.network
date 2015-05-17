//
//  LoginViewController.m
//  Hydro
//
//  Created by kevinzhow on 14/12/25.
//  Copyright (c) 2014年 Catch Inc. All rights reserved.
//

#import "LoginViewController.h"
#import <AFNetworking.h>
#import "GVUserDefaults+Hydro.h"
#import <SVProgressHUD.h>
#import "VPNStations.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *letterTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(highlightLetter:)];
    [self.view addGestureRecognizer:letterTapRecognizer];
    self.view.backgroundColor = [UIColor clearColor];

    
    self.emailtextfield.delegate = self;
    self.passwordField.delegate = self;
    self.passwordField.adjustsFontSizeToFitWidth = YES;
    self.passwordField.minimumFontSize = 12;
    
    self.emailtextfield.adjustsFontSizeToFitWidth = YES;
    self.emailtextfield.minimumFontSize = 12;
    
    self.passwordField.textEdgeInsets = UIEdgeInsetsMake(0.0f, 40.0f, 10.0f, 10.0f);
    
    UIFont *font = [UIFont fontWithName:@"Avenir-Medium" size:17.0];
    NSDictionary *attrsDictionary =
    [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,
     [UIColor colorWithWhite:1.0 alpha:0.5], NSForegroundColorAttributeName,
     nil];

    NSAttributedString *attrString =
    [[NSAttributedString alloc] initWithString:@"Password"
                                    attributes:attrsDictionary];
    
    NSAttributedString *attrEmailString =
    [[NSAttributedString alloc] initWithString:@"Email"
                                    attributes:attrsDictionary];
    
    self.passwordField.attributedPlaceholder = attrString;
    
    self.emailtextfield.attributedPlaceholder = attrEmailString;
    
    self.emailtextfield.textEdgeInsets = UIEdgeInsetsMake(0.0f, 40.0f, 10.0f, 10.0f);
    
    // Do any additional setup after loading the view.
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailtextfield)
    {
        [self.emailtextfield resignFirstResponder];
        [self.passwordField becomeFirstResponder];
    }
    else if (textField == self.passwordField)
    {
        [self.passwordField resignFirstResponder];
        
        [self doClickLoginButton:self];
    }
    
    return true;
}


-(IBAction) highlightLetter:(UITapGestureRecognizer*)recognizer
{
//    UIView *view = [recognizer view];
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doClickLoginButton:(id)sender {

    if (self.emailtextfield.text.length < 1 || self.passwordField.text.length < 1) {

        
        return;
        
    }
    
    [SVProgressHUD show];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{
                                 @"email": self.emailtextfield.text,
                                 @"password":self.passwordField.text
                                 };
    [manager POST:[NSString stringWithFormat:@"%@%@",[[VPNStations sharedInstance].config valueForKey:@"server"], [[VPNStations sharedInstance].config valueForKey:@"server_auth"]] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);

        
        NSString * token = [responseObject valueForKey:@"message"];
        NSString * status = [responseObject valueForKey:@"status"];
        if([status isEqualToString:@"error"]){

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // time-consuming task
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:@"Auth Error"];
                });
            });
        }else{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // time-consuming task
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            });
            [GVUserDefaults standardUserDefaults].token = token;
            

            
            [[NSNotificationCenter defaultCenter] postNotificationName:CCNFillUserInfo object:nil];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
            
            NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.catchlab.TodayExtensionSharingDefaults"];
            
            [sharedDefaults setBool:YES forKey:@"ActiveToday"];
            [sharedDefaults synchronize];   // (!!) This is crucial.
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // time-consuming task
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        });
    }];
    

}
@end
