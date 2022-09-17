#import <Foundation/Foundation.h>

#define SETTING_RUN_COUNT           @"run_count"
#define SETTING_USERNAME            @"username"
#define SETTING_PUSHTOKEN           @"pushtoken"


@interface Settings : NSObject

+ (void) setUsername:(NSString*)username;
+ (NSString*) getUsername;

+ (void) setPushToken:(NSData*)token;
+ (NSData*) getPushToken;

@end
