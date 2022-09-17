//
//  ConfirmViewController.m
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "AppDelegate.h"
#import "ConfirmViewController.h"
#import "Misc.h"

@interface ConfirmViewController ()
{
}
@end

@implementation ConfirmViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil type:(int) type where:(NSString*)where
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.code = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navBar.shadowImage = [UIImage new];
    self.navBar.translucent = YES;
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_btn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    self.navItem.leftBarButtonItem = revealButtonItem;
    
    self.navItem.titleView = [Misc navTitle: @"Phone Verification"];
    
    //[self.codeText setText: self.code]; 
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

- (IBAction)onConfirm:(id)sender
{
    NSString *value = [self.codeText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([value length] == 0)
    {
        [Misc message:@"Phone Verification" : @"Please enter the 6 digit activation code sent to your phone number!"];
        
        [self.codeText becomeFirstResponder];
        return;
    }
    
    if(![value isEqualToString: self.code])
    {
        [Misc message:@"Phone Verification" : @"Invalid activation code!"];
        
        [self.codeText becomeFirstResponder];
        return;
    }

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Phone Verification" message:@"Phone number verification successful!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
    
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[AppDelegate rootController] popViewControllerAnimated: YES];
    
    [self.delegate confirmSuccessful];
}
@end
