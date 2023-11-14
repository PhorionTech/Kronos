
//  TCCLog.h
//  tcc-kronos




#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCCLog : NSObject

@property NSString* message;

@property NSDate* timestamp;
@property NSString* type;
@property NSString* msgID;
@property NSString* function;

@property NSMutableDictionary* data;

- (id)init:(id)log;
- (id)initFromString:(NSString*)message;

@end

NS_ASSUME_NONNULL_END
