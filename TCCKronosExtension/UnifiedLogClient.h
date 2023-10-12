
//  UnifiedLogClient.h
//  TCCKronosExtension




#import <Foundation/Foundation.h>

@class TCCLog;

NS_ASSUME_NONNULL_BEGIN

@interface UnifiedLogClient : NSObject

@property NSDate* lastPoll;

- (int)retrieveLatestEvents:(void (^)(TCCLog* log))callback;

@end

NS_ASSUME_NONNULL_END
