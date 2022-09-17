//
//  AddressViewController.h
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddressViewDelegate <NSObject>

@optional
- (void) addressSelected: (NSString *)address;

@end


@interface AddressViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, NSURLConnectionDelegate>

@property (nonatomic,strong) id <AddressViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (weak, nonatomic) IBOutlet UIImageView *searchImage;

@property (weak, nonatomic) IBOutlet UITableView *searchTable;

@property NSString *cellIdentifier;
@property (nonatomic, strong) NSMutableArray* dataList;

@property NSString *address;

- (IBAction)onTextChanged:(id)sender;
@end
