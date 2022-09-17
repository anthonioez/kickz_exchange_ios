#import "Settings.h"


@implementation Settings
+ (void) setUsername:(NSString *)title
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: title forKey: SETTING_USERNAME];
}

+ (NSString*) getUsername
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *data = [defaults valueForKey: SETTING_USERNAME];
    if(data == nil)
        return @"";
    else
        return data;
}

+ (void) setPushToken:(NSData *)token
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: token forKey: SETTING_PUSHTOKEN];
}

+ (NSData*) getPushToken
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults valueForKey: SETTING_PUSHTOKEN];
    return data;
}
@end
