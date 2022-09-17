//
//  AppDelegate.h
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SplashViewController.h"
#import "PayPalMobile.h"

#define GOOGLE_API_KEY  @""

#define PAYPAL_CLIENT_ID_PROD  nil
#define PAYPAL_CLIENT_ID_SAND  @""


#define PAYPAL_ENVIRONMENT  PayPalEnvironmentNoNetwork

@interface AppDelegate : UIResponder <UIApplicationDelegate, SplashViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


+ (UINavigationController *)rootController;
+ (UIColor *) activeColor;

@end

