#import <Foundation/Foundation.h>

@interface AnalyticsBridge : NSObject
+ (instancetype)shared;
- (void)logEvent:(NSString *)name parameters:(NSDictionary<NSString *, NSString *> *)parameters;
- (void)setUserId:(NSString *)userId;
- (void)setUserProperty:(NSString *)name value:(NSString *)value;
- (void)resetAnalyticsData;
@end
