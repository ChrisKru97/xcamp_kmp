#import <Foundation/Foundation.h>

@protocol CrashlyticsBridge

- (void)setUserId:(NSString *)userId;
- (void)setCustomKey:(NSString *)key value:(NSString *)value;
- (void)recordException:(NSString *)message;
- (void)log:(NSString *)message;

@end
