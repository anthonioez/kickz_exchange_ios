//
//  PaymentViewController.h
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"

@protocol PaymentViewDelegate <NSObject>

@optional
- (void) paymentSuccessful;

@end

@interface PaymentViewController : UIViewController<PayPalFuturePaymentDelegate, UIAlertViewDelegate>

@property (nonatomic,strong) id <PaymentViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;

@end
