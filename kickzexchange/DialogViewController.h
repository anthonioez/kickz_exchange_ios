#import <UIKit/UIKit.h>


@interface DialogViewController : UIViewController

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UITextView *messageLabel;
- (IBAction)onOK:(id)sender;
@end
