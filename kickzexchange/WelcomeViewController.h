//
//  WelcomeViewController.h
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "VerifyViewController.h"
#import "PaymentViewController.h"

@interface WelcomeViewController : UIViewController<RegisterViewDelegate, LoginViewDelegate, VerifyViewDelegate, PaymentViewDelegate>

- (IBAction)onRegister:(id)sender;
- (IBAction)onLogin:(id)sender;
- (IBAction)onSkip:(id)sender;

@end
