#import <UIKit/UIKit.h>

@protocol SplashViewDelegate <NSObject>

@optional
- (void) splashFinished;

@end

@interface SplashViewController : UIViewController

@property (nonatomic,strong) id <SplashViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *logoImage;

@end
