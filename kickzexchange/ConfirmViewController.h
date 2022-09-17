//
//  ConfirmViewController.h
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"

@protocol ConfirmViewDelegate <NSObject>

@optional
- (void) confirmSuccessful;

@end

@interface ConfirmViewController : UIViewController<UIAlertViewDelegate>

@property (nonatomic,strong) id <ConfirmViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;

@property NSString *code;
- (IBAction)onConfirm:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *codeText;
@end
