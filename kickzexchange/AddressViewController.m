//
//  AddressViewController.m
//  kickzexchange
//
//  Created by Anthonio Ez on 4/16/15.
//  Copyright (c) 2015 Freelancer. All rights reserved.
//

#import "AppDelegate.h"
#import "AddressViewController.h"
#import "AddressViewCell.h"
#import "Misc.h"

@interface AddressViewController ()
{
    NSString *selected;
    UIBarButtonItem *acceptButtonItem;
    UIBarButtonItem *backButtonItem;
    
    NSURLConnection *loaderConnection;
    NSMutableData *loaderData;
}
@end

@implementation AddressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.dataList = [[NSMutableArray alloc] init];
        self.address = @"";
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
    
    self.navItem.titleView = [Misc navTitle: @"Find Address"];
    
    [acceptButtonItem setEnabled: NO];
    
    
    self.cellIdentifier = @"AddressViewCell";
    [self.searchTable registerNib:[UINib nibWithNibName:self.cellIdentifier bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    
    [self.searchTable setDelegate:self];
    [self.searchTable setDataSource:self];
    
    [Misc decorateText:self.searchText : [AppDelegate activeColor]];
    
    [self.searchText setText: self.address];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.searchText becomeFirstResponder];
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

- (IBAction)onAccept:(id)sender
{
    if(selected == nil) return;
    
    [self.delegate addressSelected: selected];
    
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
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *item = [self.dataList objectAtIndex:indexPath.row];
    
    AddressViewCell *cell = (AddressViewCell *)[self.searchTable dequeueReusableCellWithIdentifier:self.cellIdentifier];
    cell.addressLabel.text = item;
    
    //    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selected = [self.dataList objectAtIndex:indexPath.row];
    
    selected = [selected stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    self.searchText.text = selected ;
    
    [acceptButtonItem setEnabled: YES];
}


#pragma mark - NSURLConnection
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //[self.delegate placeErrored:[error localizedDescription]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [loaderData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:loaderData options:0 error:&localError];
    
    if (localError != nil || parsedObject == nil)
    {
        return;
    }
    
    NSArray *predictions = [parsedObject valueForKey:@"predictions"];
    NSString *status = [parsedObject valueForKey:@"status"];
    
    [self.dataList removeAllObjects];
    
    if(predictions != nil && [predictions count] > 0 && status != nil && [[status lowercaseString] isEqualToString:@"ok"])
    {
        NSString *address = @"";
        
        for (NSDictionary *dic in predictions)
        {
            if(dic != nil)
            {
                address = [dic valueForKey:@"description"];
                if(address != nil && [address length] > 0)
                {
                    [self.dataList addObject: address];
                }
            }
        }
    }
    [self.searchTable reloadData];
}

#pragma mark - Functions
-(void) search
{
    [self abort];
    
    [acceptButtonItem setEnabled: NO];
    [self.dataList removeAllObjects];
    [self.searchTable reloadData];
    
    NSString *phrase = [[self.searchText.text lowercaseString] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    
    phrase = [phrase stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    phrase = [phrase stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableString *url = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&sensor=false&types=geocode&key=%@", phrase, GOOGLE_API_KEY];
    
    loaderData = [NSMutableData new];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    loaderConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void) abort
{
    if(loaderConnection != nil)
    {
        [loaderConnection cancel];
        loaderConnection = nil;
    }
}

@end
