

//  TCCHelper.h
//  TCCKronosExtension




#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCCHelper : NSObject

- (instancetype)initWithDatabase:(NSString*)databaseName inDirectory:(NSString*)databaseDir;
- (instancetype)initWithUser:(NSString*)user;
- (NSArray<NSDictionary*>*)selectAll;
- (NSDictionary*)selectRecordByClient:(NSString*)client service:(NSString*)service;
- (BOOL)resetDBPermissions:(NSString*)service forClient:(NSString*)client;
+ (id)shared;
- (BOOL)refresh;

@end

NS_ASSUME_NONNULL_END
