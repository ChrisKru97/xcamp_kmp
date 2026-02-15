#import <Foundation/Foundation.h>
#import <FirebaseAnalytics/FirebaseAnalytics.h>

// TODO simplify anyhow
@interface AnalyticsBridge : NSObject
+ (instancetype)shared;
- (void)logEvent:(NSString *)name parameters:(NSDictionary<NSString *, NSString *> *)parameters;
- (void)setUserId:(NSString *)userId;
- (void)setUserProperty:(NSString *)name value:(NSString *)value;
- (void)resetAnalyticsData;
@end

@implementation AnalyticsBridge

+ (instancetype)shared {
    static AnalyticsBridge *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)logEvent:(NSString *)name parameters:(NSDictionary<NSString *, NSString *> *)parameters {
    [FIRAnalytics logEventWithName:name parameters:parameters];
}

- (void)setUserId:(NSString *)userId {
    [FIRAnalytics setUserID:userId];
}

- (void)setUserProperty:(NSString *)name value:(NSString *)value {
    [FIRAnalytics setUserPropertyString:value forName:name];
}

- (void)resetAnalyticsData {
    [FIRAnalytics resetAnalyticsData];
}

@end
