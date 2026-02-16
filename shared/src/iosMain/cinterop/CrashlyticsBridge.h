#import <Foundation/Foundation.h>

@interface CrashlyticsBridge : NSObject

+ (instancetype)shared;
- (void)setUserId:(NSString *)userId;
- (void)setCustomKey:(NSString *)key value:(NSString *)value;
- (void)recordException:(NSString *)message;

@end
