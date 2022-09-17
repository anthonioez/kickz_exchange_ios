//
//  CountryViewController.h
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CountryViewDelegate <NSObject>

@optional
- (void) countrySelected: (NSString *)country : (NSString *)code;

@end

@interface CountryViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic,strong) id <CountryViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (weak, nonatomic) IBOutlet UIImageView *searchImage;

@property (weak, nonatomic) IBOutlet UITableView *searchTable;

@property NSString *cellIdentifier;
@property (nonatomic, strong) NSMutableArray* dataList;
@property (nonatomic, strong) NSMutableArray* searchList;

- (IBAction)onTextChanged:(id)sender;

@end
