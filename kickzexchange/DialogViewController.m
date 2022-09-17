#import "DialogViewController.h"

@interface DialogViewController ()
{    
}
@end

@implementation DialogViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"Dialog Box";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navBar.shadowImage = [UIImage new];
    self.navBar.translucent = YES;

    self.navItem.title = self.title;
    /*
    CALayer *layer = [self.mainView layer];
    [layer setMasksToBounds:YES];
    [layer setBorderWidth:1.0f];
    [layer setCornerRadius: 5.0f];
    [layer setBorderColor:[[UIColor grayColor] CGColor]];
*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Functions
- (void) close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onOK:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
