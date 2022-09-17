//
//  RegisterViewController.h
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressViewController.h"
#import "LoginViewController.h"

@protocol RegisterViewDelegate <NSObject>

@optional
- (void) registerSuccessful;
- (void) registerLoginSuccessful;

@end

@interface RegisterViewController : UIViewController<AddressViewDelegate, LoginViewDelegate, UITextFieldDelegate>

@property (nonatomic,strong) id <RegisterViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;



@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *userIndicator;
@property (weak, nonatomic) IBOutlet UITextField *userText;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *addressText;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *password2Text;

@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UILabel *termsLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)onAddress:(id)sender;
- (IBAction)onRegister:(id)sender;

@end
