#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import <CommonCrypto/CommonDigest.h>

#import "Reachability.h"

@interface Misc : NSObject

+ (void) message:(NSString *)title :(NSString *)message;

+ (void) decorateText: (UITextField *) text : (UIColor *)color;

+ (UILabel *) navTitle: (NSString *) title;

+ (BOOL) connected;

+ (BOOL) isValidEmail:(NSString *)checkString;

+ (NSString *) md5: (NSString *)input;

+ (NSString *) secret;

@end
