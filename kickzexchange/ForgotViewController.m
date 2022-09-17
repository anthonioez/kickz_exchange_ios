//
//  ForgotViewController.m
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "ForgotViewController.h"
#import "Misc.h"

#define URL_FORGOT  @"http://baryapp.com/kickzexchange/index.php/api/getForgotPassword"

@interface ForgotViewController ()
{
    NSString *email;
    NSURLConnection *loginConnection;
    NSMutableData *loginData;
    
    MBProgressHUD *hud;
    
    UITapGestureRecognizer *tapGesture;
    CGSize keyboardSize;
    UITextField *currentTextField;
}
@end

@implementation ForgotViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
        
    self.navItem.titleView = [Misc navTitle: @"Forgot Password"];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    
    [Misc decorateText: self.emailText : [AppDelegate activeColor]];
    [self.emailText addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
   
    self.emailText.delegate = self;
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view addGestureRecognizer: tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view removeGestureRecognizer: tapGesture];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    CGFloat phyActiveY = activeRect.origin.y + scrollRect.origin.y;
    
    CGFloat offsetY = 0;
    
    if(lowerY < phyActiveY)
    {
        CGFloat diffY = (phyActiveY - lowerY) / 2;
        
        offsetY = activeRect.origin.y - activeRect.size.height/2 - diffY ;
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

- (IBAction)onForgot:(id)sender {
    if(![self validate])
    {
        return;
    }
    
    [self hideKeyboard];
    
    [self forgot];
}

#pragma mark - Functions
- (void) hideKeyboard
{
    [self.view becomeFirstResponder];
    
    [self.emailText resignFirstResponder];
    
    [self keyboardUnscroll];
}

- (void) startUI
{
    [hud show:YES];
    [self.emailText setEnabled: NO];
    [self.forgotButton setEnabled: NO];
}

- (void) stopUI
{
    [hud hide:YES];
    [self.emailText setEnabled: YES];
    [self.forgotButton setEnabled: YES];
}


-(BOOL) validate
{
    email = [self.emailText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![Misc isValidEmail: email])
    {
        [Misc message:@"Forgot Password" : @"Please enter your email address!"];
        
        [self.emailText becomeFirstResponder];
        return false;
    }
    
    return true;
}

- (void) forgot
{
    if(![Misc connected])
    {
        [Misc message:@"Forgot Password Error" : @"No internet connection"];
        return;
    }
    
    [self startUI];
    
    NSString *url = URL_FORGOT;
    
    NSString *post =[[NSString alloc] initWithFormat:@"email_id=%@&secret_key=%@", email, [Misc secret]];
    
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
    [Misc message:@"Forgot Password Error" : [error localizedDescription]];
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
        [Misc message:@"Forgot Password Error" : @"Invalid data from server!"];
        return;
    }
    
    BOOL result = [[parsedObject valueForKey:@"Result"] boolValue];
    NSString *msg = [parsedObject valueForKey:@"Message"];
    
    if(!result)
    {
        if(msg == nil || [msg length] == 0) msg = @"No message from server!";
        [Misc message:@"Forgot Password Error" : msg];
        return;
    }
    
    if(msg == nil || [msg length] == 0) msg = @"Forgot password request sent to server!";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Forgot Password" message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[AppDelegate rootController] popViewControllerAnimated: YES];
}

@end