//
//  PaymentViewController.m
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "AppDelegate.h"
#import "Misc.h"
#import "PaymentViewController.h"
#import "PayPalMobile.h"
#import "MBProgressHUD.h"
#import "Settings.h"

#define URL_PAYMENT     @"http://baryapp.com/kickzexchange/index.php/api/sendPaymentInfo.php"
//http://baryapp.com/webservices/payment_info.php

@interface PaymentViewController ()
{
    MBProgressHUD *hud;
    
    NSURLConnection *paymentConnection;
    NSMutableData *paymentData;
}
@end

@implementation PaymentViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(int) type where:(NSString*)where
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _payPalConfig = [[PayPalConfiguration alloc] init];
    _payPalConfig.acceptCreditCards = YES;
    _payPalConfig.merchantName = @"KickzExchange";
    _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    
    [PayPalMobile preconnectWithEnvironment: PAYPAL_ENVIRONMENT];
    
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.removeFromSuperViewOnHide = NO;
    [self.navigationController.view addSubview:hud];
    
    [self.navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navBar.shadowImage = [UIImage new];
    self.navBar.translucent = YES;
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_btn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    self.navItem.leftBarButtonItem = revealButtonItem;
    
    self.navItem.titleView = [Misc navTitle: @"Payment Verification"];
    
    [self paypal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (IBAction)onBack:(id)sender
{
    [[AppDelegate rootController] popViewControllerAnimated: YES];
}

#pragma mark - Functions
- (void) paypal
{
    PayPalFuturePaymentViewController *futurePaymentViewController = [[PayPalFuturePaymentViewController alloc] initWithConfiguration:self.payPalConfig delegate:self];
    [self presentViewController:futurePaymentViewController animated:YES completion:nil];
}

- (void) proceed
{
    [[AppDelegate rootController] popViewControllerAnimated: NO];
    
    [self.delegate paymentSuccessful];
}

- (void) startUI
{
    [hud show:YES];
}

- (void) stopUI
{
    [hud hide:YES];
}

- (void) process:(NSDictionary *)authorization
{
    if(authorization == nil)
    {
        [Misc message:@"Paypal Error" : @"Invalid authorization!"];
        return;
    }
    
    NSDictionary *response = [authorization valueForKey:@"response"];
    NSString *authcode = [response valueForKey:@"code"];
    
    NSString *metadata = [PayPalMobile clientMetadataID];
    
    NSString *username = [Settings getUsername];
    
    if(![Misc connected])
    {
        [Misc message:@"Payment Verification Error" : @"No internet connection!"];
        return;
    }
    
    [self startUI];
    
    NSString *url = URL_PAYMENT;
        
    NSString *post =[[NSString alloc] initWithFormat:@"username=%@&auth_code=%@&client_metadata_id=%@&secret_key=%@", username, authcode, metadata, [Misc secret]];
    
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
    
    paymentData = [NSMutableData new];
    paymentConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - NSURLConnection
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopUI];
    [Misc message:@"Payment Verification Error" : [error localizedDescription]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [paymentData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self stopUI];
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:paymentData options:0 error:&localError];
    
    if (localError != nil || parsedObject == nil)
    {
        [Misc message:@"Payment Verification Error" : @"Invalid data from server!"];
        return;
    }
    
    BOOL result = [[parsedObject valueForKey:@"Result"] boolValue];
    NSString *msg = [parsedObject valueForKey:@"Message"];
    
    if(!result)
    {
        if(msg == nil || [msg length] == 0) msg = @"No message from server!";
        [Misc message:@"Payment Verification Error" : msg];
        return;
    }
    
    if(msg == nil || [msg length] == 0) msg = @"Payment verified!";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Payment Verification" message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
    
}

#pragma mark - PayPalFuturePaymentDelegate methods

- (void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController
                didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self process: futurePaymentAuthorization];
}

- (void)payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self onBack: nil];
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self proceed];
}
@end
