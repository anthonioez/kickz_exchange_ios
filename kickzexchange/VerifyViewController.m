//
//  VerifyViewController.m
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "VerifyViewController.h"
#import "ConfirmViewController.h"
#import "CountryViewController.h"
#import "Misc.h"

#define URL_SEND_SMS    @"http://baryapp.com/webservices/send_sms.php"

@interface VerifyViewController ()
{
    NSString *number;
    NSString *seed;
    NSString *code;
    MBProgressHUD *hud;
    NSURLConnection *loginConnection;
    NSMutableData *loginData;
    
    UITapGestureRecognizer *tapGesture;
    CGSize keyboardSize;
    UITextField *currentTextField;
}
@end

@implementation VerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
        
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
        
    self.navItem.titleView = [Misc navTitle: @"Phone Verification"];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    
    [Misc decorateText:self.numberText : [AppDelegate activeColor]];
    
    self.numberText.delegate = self;
    
    code = @"+91";
    seed = @"";
    srand((unsigned int)[[NSDate new] timeIntervalSince1970]);
    for(int i = 0; i < 6; i++)
    {
        int n = rand() % 10;
        seed = [seed stringByAppendingString: [NSString stringWithFormat:@"%d", n]];
    }
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navBar removeGestureRecognizer: tapGesture];
    [self.view removeGestureRecognizer: tapGesture];
    
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

- (IBAction)onVerify:(id)sender
{
    if(![self validate])
    {
        return;
    }
    
    [self hideKeyboard];
    
    [self verify];
}

- (IBAction)onCountry:(id)sender
{
    CountryViewController *countryController = [[CountryViewController alloc] initWithNibName:@"CountryViewController" bundle:nil];
    countryController.delegate = self;
    [[AppDelegate rootController] pushViewController: countryController animated:YES];
}

#pragma mark - CountryViewDelegate
- (void) countrySelected:(NSString *)country :(NSString *)cc
{
    code = cc;
    
    [self.codeLabel setText: cc];
    [self.countryButton setTitle:country forState:UIControlStateNormal];
}

#pragma mark - Tap Handlers
- (void) hideKeyboard
{
    [self.view becomeFirstResponder];
    
    [self.numberText resignFirstResponder];
    
    CGPoint pt = CGPointZero;
    [self.scrollView setContentOffset:pt animated:YES];
}

#pragma mark - Functions
- (void) startUI
{
    [hud show:YES];
    [self.verifyButton setEnabled: NO];
}

- (void) stopUI
{
    [hud hide:YES];
    
    [self.verifyButton setEnabled: YES];
}


-(BOOL) validate
{
    number = [self.numberText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([number length] == 0)
    {
        [Misc message:@"Phone Verification" : @"Please enter your phone number!"];
        
        [self.numberText becomeFirstResponder];
        return false;
    }
    
    if([number hasPrefix:@"0"])
    {
        number = [number substringFromIndex:1];
    }
       
    number = [code stringByAppendingString: number];
    
    if([number hasPrefix:@"+"])
    {
        //number = [number substringFromIndex:1];
    }
    return true;
}

- (void) verify
{
    if(![Misc connected])
    {
        [Misc message:@"Phone Verification Error" : @"No internet connection"];
        return;
    }
    
    [self startUI];
    
    NSString *url = URL_SEND_SMS;
    
    NSString *post =[[NSString alloc] initWithFormat:@"to_mobile=%@&verify_code=%@&secret_key=%@", number, seed, [Misc secret]];
    
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
    [Misc message:@"Phone Verification Error" : [error localizedDescription]];
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
        [Misc message:@"Phone Verification Error" : @"Invalid data from server!"];
        return;
    }
    
    BOOL result = [[parsedObject valueForKey:@"Result"] boolValue];
    NSString *msg = [parsedObject valueForKey:@"Message"];
    
    //result = true;  //TODO
    
    if(!result)
    {
        if(msg == nil || [msg length] == 0) msg = @"Unable to send verification request!";
        [Misc message:@"Phone Verification Error" : msg];
        return;
    }
    
    //    BOOL vPayment = [[parsedObject valueForKey:@"isPaymentVerified"] boolValue];
    //    BOOL vEmail = [[parsedObject valueForKey:@"isEmailVerfied"] boolValue];
    //    BOOL vMobile = [[parsedObject valueForKey:@"isMobileVerified"] boolValue];
    if(msg != nil && [msg length] != 0)
    {
        //[Misc message:@"Phone Verification" : msg];
    }
    
    [[AppDelegate rootController] popViewControllerAnimated: NO];
    
    ConfirmViewController *confirmController = [[ConfirmViewController alloc] initWithNibName:@"ConfirmViewController" bundle:nil];
    confirmController.code = seed;
    confirmController.delegate = self;
    [[AppDelegate rootController] pushViewController: confirmController animated:YES];

}

- (void) confirmSuccessful
{
    [self.delegate verifySuccessful];
}

@end
