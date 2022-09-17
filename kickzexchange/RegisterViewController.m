//
//  RegisterViewController.m
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "AppDelegate.h"
#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "AddressViewController.h"
#import "VerifyViewController.h"
#import "MBProgressHUD.h"
#import "Misc.h"
#import "Settings.h"
#import "DialogViewController.h"

#define URL_REGISTER    @"http://baryapp.com/kickzexchange/index.php/api/registerUser"
#define URL_CHECK_NAME  @"http://baryapp.com/kickzexchange/index.php/api/checkUsername"

@interface RegisterViewController ()
{
    NSString *username;
    NSString *name;
    NSString *email;
    NSString *address;
    NSString *password;
    NSString *version;
    
    MBProgressHUD *hud;
    NSURLConnection *registerConnection;
    NSMutableData *registerData;

    
    NSURLConnection *checkConnection;
    NSMutableData *checkData;
    
    BOOL checking;

    UITapGestureRecognizer *tapGesture;
    UITapGestureRecognizer *adrGesture;
    UITapGestureRecognizer *logGesture;
    UITapGestureRecognizer *tosGesture;
    
    NSMutableAttributedString *loginAttributedString;
    NSRange loginLinkRange;

    NSMutableAttributedString *termsAttributedString;
    NSRange termsLinkRange;
    
    CGSize keyboardSize;
    UITextField *currentTextField;

}
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    checking = false;
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
    
    self.navItem.titleView = [Misc navTitle: @"Register"];
    
    [self.addressText setEnabled: NO];
    
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    
    adrGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAddress:)];
    adrGesture.cancelsTouchesInView = NO;
    
    logGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLoginTap:)];
    logGesture.cancelsTouchesInView = NO;
    
    tosGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTermsTap:)];
    tosGesture.cancelsTouchesInView = NO;
    
    NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:136/255.0f green:219/255.0f blue:209/255.0f alpha:1.0], NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) };

    NSString *login = @"Already have an account? Login Now";
    loginLinkRange = [login rangeOfString:@"Login Now"];
    
    loginAttributedString = [[NSMutableAttributedString alloc] initWithString:login attributes:nil];
    [loginAttributedString setAttributes:linkAttributes range:loginLinkRange];
    
    self.loginLabel.attributedText = loginAttributedString;
    self.loginLabel.userInteractionEnabled = YES;
    
    
    NSString *terms = @"By clicking Create Account, you are agreeing to out Terms of Service";
    termsLinkRange = [terms rangeOfString:@"Terms of Service"];
    
    termsAttributedString = [[NSMutableAttributedString alloc] initWithString:terms attributes:nil];
    [termsAttributedString setAttributes:linkAttributes range:termsLinkRange];
    
    self.termsLabel.attributedText = termsAttributedString;
    self.termsLabel.userInteractionEnabled = YES;
    
    
    UIColor *color = [AppDelegate activeColor];
    
    [Misc decorateText: self.userText : color];
    [Misc decorateText: self.emailText : color];
    [Misc decorateText: self.nameText : color];
    [Misc decorateText: self.addressText : color];
    [Misc decorateText: self.passwordText : color];
    [Misc decorateText: self.password2Text : color];
    
    [self.userText addTarget:self.nameText  action:@selector(becomeFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
//    [self.nameText addTarget:self.emailText  action:@selector(becomeFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.nameText addTarget:self  action:@selector(onAddress:) forControlEvents:UIControlEventEditingDidEndOnExit];

    [self.emailText addTarget:self.passwordText  action:@selector(becomeFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordText addTarget:self.password2Text  action:@selector(becomeFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.password2Text addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.userIndicator stopAnimating];
    [self.userImage setHidden: YES];
    
    self.userText.delegate = self;
    self.nameText.delegate = self;
    self.emailText.delegate = self;
    self.passwordText.delegate = self;
    self.password2Text.delegate = self;
    
    version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    /*
    self.userText.text = @"tonyshak";
    self.nameText.text = @"Tony Shakur";
    self.emailText.text = @"dtonyshakur@gmail.com";
    self.addressText.text = @"Nigeria";
    self.passwordText.text = @"123456";
    self.password2Text.text = @"123456";
    */
}

        
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view addGestureRecognizer: tapGesture];
    [self.navBar addGestureRecognizer: tapGesture];
    [self.addressView addGestureRecognizer: adrGesture];
    [self.loginLabel addGestureRecognizer: logGesture];
    [self.termsLabel addGestureRecognizer: tosGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view removeGestureRecognizer: tapGesture];
    [self.navBar removeGestureRecognizer: tapGesture];
    [self.addressView removeGestureRecognizer: adrGesture];
    [self.loginLabel removeGestureRecognizer: logGesture];
    [self.termsLabel removeGestureRecognizer: logGesture];
    
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.userText)
    {
        if(range.length == 0)
        {
            if([textField.text length] == 7)
            {
                [self check];
                return YES;
            }
            else if([textField.text length] >= 8)
            {
                [self.nameText becomeFirstResponder];
                return NO;
            }
        }
        
        [self checkabort];
        
        [self.userIndicator stopAnimating];
        
        [self.userImage setHidden: YES];
    }
    
    return YES;
}

#pragma mark - Functions
- (void) showLogin
{
    LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    loginController.delegate = self;
    [[AppDelegate rootController] pushViewController: loginController animated:YES];
}

- (void) showTerms
{
    DialogViewController *dialogController = [[DialogViewController alloc] initWithNibName:@"DialogViewController" bundle:nil];
    dialogController.title = @"End User License Agreement";
    dialogController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController: dialogController animated:YES completion:nil];
}

#pragma mark - Tap Handlers
- (void)handleLoginTap:(UITapGestureRecognizer *)tapLogGesture
{
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:loginAttributedString];
    
    // Configure layoutManager and textStorage
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    // Configure textContainer
    textContainer.lineFragmentPadding = 0.0;
    textContainer.lineBreakMode = self.loginLabel.lineBreakMode;
    textContainer.maximumNumberOfLines = self.loginLabel.numberOfLines;
    
    CGPoint locationOfTouchInLabel = [tapLogGesture locationInView: tapLogGesture.view];
    CGSize labelSize = tapLogGesture.view.bounds.size;
    
    CGRect textBoundingBox = [layoutManager usedRectForTextContainer: textContainer];
    CGPoint textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
    
    CGPoint locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                         locationOfTouchInLabel.y - textContainerOffset.y);
    
    NSInteger indexOfCharacter = [layoutManager characterIndexForPoint:locationOfTouchInTextContainer
                                                       inTextContainer:textContainer
                              fractionOfDistanceBetweenInsertionPoints:nil];
    
    if (NSLocationInRange(indexOfCharacter, loginLinkRange))
    {
        [self showLogin];
    }
    
}

- (void)handleTermsTap:(UITapGestureRecognizer *)tapLogGesture
{
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:termsAttributedString];
    
    // Configure layoutManager and textStorage
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    // Configure textContainer
    textContainer.lineFragmentPadding = 0.0;
    textContainer.lineBreakMode = self.termsLabel.lineBreakMode;
    textContainer.maximumNumberOfLines = self.termsLabel.numberOfLines;
    
    CGPoint locationOfTouchInLabel = [tapLogGesture locationInView: tapLogGesture.view];
    CGSize labelSize = tapLogGesture.view.bounds.size;
    
    CGRect textBoundingBox = [layoutManager usedRectForTextContainer: textContainer];
    CGPoint textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
    
    CGPoint locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                         locationOfTouchInLabel.y - textContainerOffset.y);
    
    NSInteger indexOfCharacter = [layoutManager characterIndexForPoint:locationOfTouchInTextContainer
                                                       inTextContainer:textContainer
                              fractionOfDistanceBetweenInsertionPoints:nil];
    
    if (NSLocationInRange(indexOfCharacter, termsLinkRange))
    {
        [self showTerms];
    }
    
}

- (void) hideKeyboard
{
    [self.userText resignFirstResponder];
    [self.nameText resignFirstResponder];
    [self.addressText resignFirstResponder];
    [self.emailText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    [self.password2Text resignFirstResponder];
    
    [self.view becomeFirstResponder];
    
    CGPoint pt = CGPointZero;
    [self.scrollView setContentOffset:pt animated:YES];
}

#pragma mark - AddressViewDelegate
- (void) addressSelected:(NSString *)addr
{
    self.addressText.text = addr;
    
    [self.emailText becomeFirstResponder];
}

#pragma mark - IBActions
- (IBAction)onBack:(id)sender
{
    [[AppDelegate rootController] popViewControllerAnimated: YES];
}

- (IBAction)onAddress:(id)sender {
    [self.addressText resignFirstResponder];
    [self keyboardUnscroll];
    
    AddressViewController *addressController = [[AddressViewController alloc] initWithNibName:@"AddressViewController" bundle:nil];
    addressController.delegate = self;
    addressController.address = self.addressText.text;
    [[AppDelegate rootController] pushViewController: addressController animated:YES];
}

- (IBAction)onRegister:(id)sender
{
    if(![self validate])
    {
        return;
    }
    
    [self hideKeyboard];
    
    [self create];
}

#pragma mark - Functions
- (void) startUI
{
    if(checking)
    {
        [self.userIndicator startAnimating];
        [self.userImage setHidden: YES];
    }
    else
    {
        [self.userIndicator stopAnimating];
        [hud show:YES];
        [self.registerButton setEnabled: NO];
    }
}

- (void) stopUI
{
    if(checking)
    {
        [self.userIndicator stopAnimating];
    }
    else
    {
        [self.userIndicator stopAnimating];
        [hud hide:YES];
        [self.registerButton setEnabled: YES];
    }
}

-(BOOL) validate
{
    username = [self.userText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    name = [self.nameText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    email = [self.emailText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    password = [self.passwordText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    address = [self.addressText.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    NSString *pass = [self.password2Text.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    if ([username length] < 4)
    {
        [Misc message:@"Register" : @"Please enter your username!"];
        
        [self.userText becomeFirstResponder];
        return false;
    }
    
    if ([name length] < 4)
    {
        [Misc message:@"Register" : @"Please enter your fullname!"];
        
        [self.nameText becomeFirstResponder];
        return false;
    }
    
    if([address length] == 0)
    {
        [Misc message:@"Register" : @"Please specify your address!"];
        
        return false;
    }
    
    if (![Misc isValidEmail: email])
    {
        [Misc message:@"Register" : @"Please enter your email address!"];
        
        [self.emailText becomeFirstResponder];
        return false;
    }
    
    if ([password length] < 4)
    {
        [Misc message:@"Register" : @"Please enter your password (minimum of 4 characters)!"];
        
        [self.passwordText becomeFirstResponder];
        return false;
    }
    
    if ([pass length] < 4)
    {
        [Misc message:@"Register" : @"Please re-enter your password (minimum of 4 characters)!"];
        
        [self.password2Text becomeFirstResponder];
        return false;
    }
    
    if(![password isEqualToString:pass])
    {
        [Misc message:@"Register" : @"Mismatch! Please re-enter your password (minimum of 4 characters)!"];
        
        [self.password2Text becomeFirstResponder];
        return false;
    }
    
    address = [address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    address = [address stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    address = [address stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    //name = [name stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    return true;
}

- (void) create
{
    if(![Misc connected])
    {
        [Misc message:@"Register Error" : @"No internet connection"];
        return;
    }
    
    if(checking)
    {
        [self checkabort];
    }
    
    NSData *token = nil;    //[Settings getPushToken];

    checking = false;
    [self startUI];
    
    NSString *url = URL_REGISTER;
    
    NSString *post =[[NSString alloc] initWithFormat:@"username=%@&name=%@&address=%@&email_id=%@&password=%@&device_id=%@&app_version=%@&platform=%@&secret_key=%@",
                     username, name, address, email, password, token, version, @"iOS", [Misc secret]];
    
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
    
    registerData = [NSMutableData new];
    registerConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void) checkabort
{
    if(checkConnection != nil)
    {
        [checkConnection cancel];
        checkConnection = nil;
    }
}

- (void) check
{
    if(![Misc connected])
    {
        return;
    }
    
    [self checkabort];
    
    checking = true;
    [self startUI];

    username = [self.userText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *url = URL_CHECK_NAME;
    
    NSString *post =[[NSString alloc] initWithFormat:@"username=%@&secret_key=%@", username, [Misc secret]];
    
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
    
    checkData = [NSMutableData new];
    checkConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - NSURLConnection
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopUI];
    if(connection == registerConnection)
    {
        [Misc message:@"Register Error" : [error localizedDescription]];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(connection == registerConnection)
        [registerData appendData:data];
    else
        [checkData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self stopUI];
    
    if(connection == registerConnection)
    {
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:registerData options:0 error:&localError];
        
        if (localError != nil || parsedObject == nil)
        {
            [Misc message:@"Register Error" : @"Invalid data from server!"];
            return;
        }
        
        BOOL result = [[parsedObject valueForKey:@"Result"] boolValue];
        NSString *msg = [parsedObject valueForKey:@"Message"];
        if(!result)
        {
            if(msg == nil || [msg length] == 0) msg = @"Unable to register your account!";
            [Misc message:@"Register Error" : msg];
            return;
        }
        
        if(msg != nil && [msg length] != 0)
        {
            [Misc message:@"Register" : msg];
        }
        
        [Settings setUsername: username];
        
        [[AppDelegate rootController] popViewControllerAnimated: NO];
        
        [self.delegate registerSuccessful];
    }
    else
    {
        NSError *localError = nil;
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:checkData options:0 error:&localError];
        
        if (localError != nil && parsedObject != nil)
        {
            [self.userImage setHidden: YES];
            return;
        }
        
        [self.userImage setHidden: NO];
        BOOL result = [[parsedObject valueForKey:@"Result"] boolValue];
        if(result)
        {
            [self.userImage setImage: [UIImage imageNamed: @"ic_available.png"]];
        }
        else
        {
            [self.userImage setImage: [UIImage imageNamed: @"ic_not_available.png"]];
        }
    }
}

#pragma mark - LoginViewDelegate
- (void) loginSuccessful
{    
    
    [[AppDelegate rootController] popViewControllerAnimated: YES];
    [self.delegate registerLoginSuccessful];
}

@end
