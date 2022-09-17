//
//  VerifyViewController.h
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryViewController.h"
#import "ConfirmViewController.h"

@protocol VerifyViewDelegate <NSObject>

@optional
- (void) verifySuccessful;
@end

@interface VerifyViewController : UIViewController<CountryViewDelegate, ConfirmViewDelegate, UITextFieldDelegate>

@property (nonatomic,strong) id <VerifyViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@property (weak, nonatomic) IBOutlet UIButton *countryButton;
@property (weak, nonatomic) IBOutlet UITextField *numberText;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;

- (IBAction)onVerify:(id)sender;
- (IBAction)onCountry:(id)sender;
@end
