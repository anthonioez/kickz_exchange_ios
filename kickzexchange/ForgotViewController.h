//
//  ForgotViewController.h
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotViewController : UIViewController<UIAlertViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)onForgot:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *forgotLabel;
@end
