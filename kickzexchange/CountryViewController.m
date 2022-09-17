//
//  CountryViewController.m
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "AppDelegate.h"
#import "CountryItem.h"
#import "CountryViewCell.h"
#import "CountryViewController.h"
#import "Misc.h"

@interface CountryViewController ()
{
    CountryItem *selected;
    UIBarButtonItem *acceptButtonItem;
    UIBarButtonItem *backButtonItem;
}
@end

@implementation CountryViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.dataList = [[NSMutableArray alloc] init];
        self.searchList = [[NSMutableArray alloc] init];

        selected = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navBar.shadowImage = [UIImage new];
    self.navBar.translucent = YES;
    
    backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_btn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack:)];
    self.navItem.leftBarButtonItem = backButtonItem;
    
    acceptButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"accept_btn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onAccept:)];
    self.navItem.rightBarButtonItem = acceptButtonItem;
    
    self.navItem.titleView = [Misc navTitle: @"Choose a country"];
    
    self.cellIdentifier = @"CountryViewCell";
    [self.searchTable registerNib:[UINib nibWithNibName:self.cellIdentifier bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    
    [self.searchTable setDelegate:self];
    [self.searchTable setDataSource:self];
        
    [Misc decorateText:self.searchText : [AppDelegate activeColor]];
    
    [self load];
    [self search];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self.searchList removeAllObjects];
    [self.dataList removeAllObjects];
    
    [self.searchTable reloadData];
}


#pragma mark - IBActions
- (IBAction)onBack:(id)sender
{
    [[AppDelegate rootController] popViewControllerAnimated: YES];
}

- (IBAction)onAccept:(id)sender
{
    if(selected == nil) return;
    
    [self.delegate countrySelected: selected.country :selected.code];
    
    [[AppDelegate rootController] popViewControllerAnimated: YES];
}


- (IBAction)onTextChanged:(id)sender {
    
    [self search];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CountryItem *item = [self.searchList objectAtIndex:indexPath.row];
    
    CountryViewCell *cell = (CountryViewCell *)[self.searchTable dequeueReusableCellWithIdentifier:self.cellIdentifier];
    cell.countryLabel.text = item.country;
    cell.codeLabel.text = item.code;
    
//    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selected = [self.searchList objectAtIndex:indexPath.row];
    
    self.searchText.text = selected.country;
    
    //[acceptButtonItem setImage: [UIImage imageNamed: @"accept_btn.png"]];
    [acceptButtonItem setEnabled: YES];
}

-(NSArray*) loadText: (NSString *)name : (NSString *)ext
{
    NSString *codePath = [[NSBundle mainBundle] pathForResource:name ofType:ext];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if(![filemgr fileExistsAtPath:codePath])
    {
        NSLog(@"text file not found!");
        return nil;
    }
    
    NSError *error = nil;   //NSASCIIStringEncoding
    NSString *codeText = [NSString stringWithContentsOfFile:codePath encoding:NSUTF8StringEncoding error: &error];
    if(codeText == nil)
    {
        NSLog(@"text file is empty!");
        return nil;
    }
    
    return [codeText componentsSeparatedByString:@"\r\n"];
}

- (void) load
{
    NSArray* codes      = [self loadText:@"idd" :@"txt"];
    NSArray* countries  = [self loadText:@"nam" :@"txt"];
    
    if(countries == nil || codes == nil) return;
        
    int count = (int)[countries count];

    if ([countries count] != count) return;
    
    [self.dataList removeAllObjects];

    for(int i = 0; i < count; i++)
    {
        CountryItem *item = [CountryItem new];
        item.country    = [[countries objectAtIndex:i] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        item.code       = [[codes objectAtIndex:i] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [self.dataList addObject: item];
    }

}

-(void) search
{
    [acceptButtonItem setEnabled: NO];
    
    NSString *phrase = [[self.searchText.text lowercaseString] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];

    [self.searchList removeAllObjects];
    
    int count = (int)[self.dataList count];
    for(int i = 0; i < count; i++)
    {
        CountryItem *item = [self.dataList objectAtIndex: i];
        NSString *country = [item.country lowercaseString];
        if([phrase length] == 0 || [country hasPrefix: phrase])
        {
            [self.searchList addObject: item];
        }
    }

    [self.searchTable reloadData];
}

@end
