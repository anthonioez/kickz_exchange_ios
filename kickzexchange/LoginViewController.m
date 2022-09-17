//
//  LoginViewController.m
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ForgotViewController.h"
#import "MBProgressHUD.h"
#import "Misc.h"
#import "Settings.h"

#define URL_CHECK_LOGIN     @"http://baryapp.com/kickzexchange/index.php/api/checkLogin"

@interface LoginViewController ()
{
    NSString *email;
    NSString *password;
    
    NSURLConnection *loginConnection;
    NSMutableData *loginData;
    
    MBProgressHUD *hud;
    UITapGestureRecognizer *tapGesture;
    UITapGestureRecognizer *forGesture;
    
    NSRange forgotLinkRange;
    NSMutableAttributedString *forgotAttributedString;

    BOOL vPayment;
    BOOL vMobile;
    BOOL vEmail;
    NSString *vMessage;
    
    CGSize keyboardSize;
    UITextField *currentTextField;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    vPayment = false;
    vMobile = false;
    vEmail = false;
    vMessage = @"";
    
    currentTextField = nil;
    keyboardSize = CGSizeMake(0, 0);
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.removeFromSuperViewOnHide = NO;
    [self.navigationController.view addSubview:hud];
    
    [self.navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navBar.shadowImage = [UIImage new];
    self.navBar.translucent = YES;
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_btn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    self.navItem.leftBarButtonItem = revealButtonItem;
    
    self.navItem.titleView = [Misc navTitle: @"Login"];
    
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    
    forGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleForgotTap)];
    forGesture.cancelsTouchesInView = NO;
    
    NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:136/255.0f green:219/255.0f blue:209/255.0f alpha:1.0], NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) };

    NSString *forgot = @"Forgot Password?";
    forgotLinkRange = [forgot rangeOfString:forgot];
    
    forgotAttributedString = [[NSMutableAttributedString alloc] initWithString:forgot attributes:nil];
    [forgotAttributedString setAttributes:linkAttributes range:forgotLinkRange];
    
    self.forgotLabel.attributedText = forgotAttributedString;
    self.forgotLabel.userInteractionEnabled = YES;
    
    UIColor *color = [AppDelegate activeColor];

    [Misc decorateText: self.emailText : color];
    [Misc decorateText: self.passwordText : color];

    self.emailText.delegate = self;
    self.passwordText.delegate = self;
    
    [self.emailText addTarget:self.passwordText  action:@selector(becomeFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordText addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];

    //TODO
    //self.emailText.text = @"dtonyshakur@gmail.com";
    //self.passwordText.text = @"123456";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navBar addGestureRecognizer: tapGesture];
    [self.view addGestureRecognizer: tapGesture];
    [self.forgotLabel addGestureRecognizer: forGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navBar removeGestureRecognizer: tapGesture];
    [self.view removeGestureRecognizer: tapGesture];
    [self.forgotLabel removeGestureRecognizer: forGesture];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - Keyboard Functions

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    keyboardSize = CGSizeMake(0, 0);
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    [self keyboardScroll];
}

- (void) keyboardUnscroll
{
    CGPoint pt = CGPointZero;
    [self.scrollView setContentOffset:pt animated:YES];
}

- (void) keyboardScroll
{    
    if(keyboardSize.height == 0)
        return;
    
    if(currentTextField == nil)
        return;
    
    CGRect frameRect = self.view.frame;
    CGRect scrollRect = self.scrollView.frame;
    CGRect activeRect = currentTextField.superview.frame;
    
    //    CGFloat upperY = scrollRect.origin.y;
    CGFloat lowerY = frameRect.size.height - keyboardSize.height;
    
    CGFloat phyActiveY = activeRect.origin.y + activeRect.size.height + scrollRect.origin.y;
    
    CGFloat offsetY = 0;
    
    if(lowerY < phyActiveY)
    {
        CGFloat diffY = (phyActiveY - lowerY) / 2;
        
        offsetY = activeRect.origin.y - diffY; //activeRect.size.height - diffY ;
    }
    
    [UIView animateWithDuration:1.0 animations:^{
        self.scrollView.contentOffset = CGPointMake(0.0, offsetY);
    }];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    currentTextField = textField;
    
    [self keyboardScroll];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

/*
 - (BOOL)textFieldShouldReturn:(UITextField *)textField
 {
 [textField resignFirstResponder];
 return YES;
 }
 */

#pragma mark - IBActions
- (IBAction)onBack:(id)sender
{
    [[AppDelegate rootController] popViewControllerAnimated: YES];
}

- (IBAction)onLogin:(id)sender {
    if(![self validate])
    {
        return;
    }
    
    [self hideKeyboard];
    
    [self login];
}


#pragma mark - Tap Handlers
- (void) hideKeyboard
{
    [self.view becomeFirstResponder];
    
    [self.emailText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    
    [self keyboardUnscroll];
}

- (void)handleForgotTap
{
    [self.emailText setText: @""];
    [self.passwordText setText: @""];
    
    ForgotViewController *forgotController = [[ForgotViewController alloc] initWithNibName:@"ForgotViewController" bundle:nil];
    [[AppDelegate rootController] pushViewController: forgotController animated:YES];
}

#pragma mark - Functions
- (void) startUI
{
    [hud show:YES];
    [self.emailText setEnabled: NO];
    [self.passwordText setEnabled: NO];
    [self.loginButton setEnabled: NO];
}

- (void) stopUI
{
    [hud hide:YES];
    
    [self.emailText setEnabled: YES];
    [self.passwordText setEnabled: YES];
    [self.loginButton setEnabled: YES];
}


-(BOOL) validate
{
    email = [self.emailText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    password = [self.passwordText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![Misc isValidEmail: email])
    {
        [Misc message:@"Login" : @"Please enter your email address!"];
        
        [self.emailText becomeFirstResponder];
        return false;
    }
    
    if ([password length] < 4)
    {
        [Misc message:@"Login" : @"Please enter your password (minimum of 4 characters)!"];
        
        [self.passwordText becomeFirstResponder];
        return false;
    }
    
    return true;
}

- (void) login
{
    if(![Misc connected])
    {
        [Misc message:@"Login Error" : @"No internet connection"];
        return;
    }
    
    [self startUI];
    
    NSString *url = URL_CHECK_LOGIN;
    
    NSString *post =[[NSString alloc] initWithFormat:@"email_id=%@&password=%@&secret_key=%@", email, password, [Misc secret]];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postSize = [NSString stringWithFormat:@"%ld", (long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setValue:postSize forHTTPHeaderField:@"Content-Length"];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:60.0];
    
    //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    
    loginData = [NSMutableData new];
    loginConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopUI];
    [Misc message:@"Login Error" : [error localizedDescription]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [loginData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self stopUI];
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:loginData options:0 error:&localError];
    
    if (localError != nil || parsedObject == nil)
    {
        [Misc message:@"Login Error" : @"Invalid data from server!"];
        return;
    }
    
    BOOL result = [[parsedObject valueForKey:@"Result"] boolValue];
    NSString *msg = [parsedObject valueForKey:@"Message"];
    if(!result)
    {
        if(msg == nil || [msg length] == 0) msg = @"Unable to login!";
        [Misc message:@"Login Error" : msg];
        return;
    }
    
    [Settings setUsername: email];
    
    vPayment = [[parsedObject valueForKey:@"isPaymentVerified"] boolValue];
    vMobile = [[parsedObject valueForKey:@"isMobileVerified"] boolValue];
    vEmail = [[parsedObject valueForKey:@"isEmailVerfied"] boolValue];
    vMessage = msg;

    if(!vMobile)
    {
        [self mobile];
        return;
    }
    else if(!vPayment)
    {
        [self payment];
        return;
    }
    else if(!vEmail)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        [self proceed];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[AppDelegate rootController] popViewControllerAnimated: YES];
}

- (void) proceed
{
    [[AppDelegate rootController] popViewControllerAnimated: YES];
    
    [self.delegate loginSuccessful];
    
}

- (void) mobile
{
    VerifyViewController *verifyController = [[VerifyViewController alloc] initWithNibName:@"VerifyViewController" bundle:nil];
    verifyController.delegate = self;
    [[AppDelegate rootController] pushViewController: verifyController animated:YES];
}

- (void) verifySuccessful
{
    if(!vPayment)
    {
        [self payment];
    }
    else if(!vEmail)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:vMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        [self proceed];
    }
}

- (void) payment
{
    PaymentViewController *paymentController = [[PaymentViewController alloc] initWithNibName:@"PaymentViewController" bundle:nil];
    paymentController.delegate = self;
    [[AppDelegate rootController] pushViewController: paymentController animated:YES];
}

- (void) paymentSuccessful
{
    if(!vEmail)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:vMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        [self proceed];
    }
}


@end
