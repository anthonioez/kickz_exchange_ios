//
//  Misc.m
//  Dayly
//
//  Created by Anthonio Ez on 1/27/15.
//  Copyright (c) 2015 Miciniti. All rights reserved.
//

#import "Misc.h"
#import "Reachability.h"

@implementation Misc

+ (void) message:(NSString *)title :(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [alertView show];
}

+ (void) decorateText: (UITextField *) text : (UIColor *)color
{
    if ([text respondsToSelector:@selector(setAttributedPlaceholder:)])
    {
        text.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    }
}

+(BOOL) isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (BOOL) connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

+ (NSString *)md5: (NSString *)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+ (NSString *) secret
{
    return [Misc md5: @"Kickz Exchange"];
}

+ (UILabel *) navTitle: (NSString *) title
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0,40,320,40)];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:16];
    
    return label;
    
}
@end
