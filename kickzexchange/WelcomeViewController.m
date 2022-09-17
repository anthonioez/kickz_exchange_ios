//
//  WelcomeViewController.m
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "VerifyViewController.h"
#import "PaymentViewController.h"
#import "BlankViewController.h"
#import "Misc.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onRegister:(id)sender
{
    RegisterViewController *registerController = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    registerController.delegate = self;
    [[AppDelegate rootController] pushViewController: registerController animated:YES];
}

- (IBAction)onLogin:(id)sender
{
    LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginController.delegate = self;
    [[AppDelegate rootController] pushViewController: loginController animated:YES];
}

- (IBAction)onSkip:(id)sender
{
    [self blank];
}

- (void) blank
{
    BlankViewController *blankController = [[BlankViewController alloc] initWithNibName:@"BlankViewController" bundle:nil];
    [[AppDelegate rootController] pushViewController: blankController animated:NO];
}

- (void) loginSuccessful
{
    [self blank];
}

- (void) registerLoginSuccessful
{
    [self loginSuccessful];
}

- (void) registerSuccessful
{
    VerifyViewController *verifyController = [[VerifyViewController alloc] initWithNibName:@"VerifyViewController" bundle:nil];
    verifyController.delegate = self;
    [[AppDelegate rootController] pushViewController: verifyController animated:YES];
}

- (void) verifySuccessful
{
    PaymentViewController *paymentController = [[PaymentViewController alloc] initWithNibName:@"PaymentViewController" bundle:nil];
    paymentController.delegate = self;
    [[AppDelegate rootController] pushViewController: paymentController animated:YES];
}

- (void) paymentSuccessful
{
    [[AppDelegate rootController] popViewControllerAnimated:YES];
}

@end
