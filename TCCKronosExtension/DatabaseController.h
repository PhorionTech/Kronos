
//  DatabaseController.h
//  tcc-kronos




#import <Foundation/Foundation.h>

@class TCCLog;

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseController : NSObject

- (instancetype)initWithDatabase:(NSString*)databaseName inDirectory:(NSString*)databaseDir;
- (BOOL)writeTCCLogToDatabase:(TCCLog*)log;
- (void)close;
- (NSDictionary*)getConditionsForService:(NSString*)service forApp:(NSString*)appIdentifier;
- (BOOL)addCondition:(NSString*)condition withValue:(NSString*)value withIdentifier:(NSString*)identifier forService:(NSString*)service forApp:(NSString*)app;
- (NSArray<NSDictionary*>*)getUsageForApp:(NSString*)appIdentifier;
- (NSArray<NSDictionary*>*)getConditions;
- (BOOL)deleteCondition:(NSDictionary*)condition;
- (NSDictionary*)getUsageByMsgID:(NSString*)msgID;

@end

NS_ASSUME_NONNULL_END
