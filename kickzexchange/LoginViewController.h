//
//  LoginViewController.h
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerifyViewController.h"
#import "PaymentViewController.h"

@protocol LoginViewDelegate <NSObject>

@optional
- (void) loginSuccessful;

@end

@interface LoginViewController : UIViewController<UIAlertViewDelegate, UITextFieldDelegate, VerifyViewDelegate, PaymentViewDelegate>
@property (nonatomic,strong) id <LoginViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UILabel *forgotLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)onLogin:(id)sender;

@end
