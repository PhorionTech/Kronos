
//  RevocationService.h
//  tcc-kronos




#import <Foundation/Foundation.h>

@class DatabaseController;

NS_ASSUME_NONNULL_BEGIN

@interface RevocationService : NSObject

- (instancetype)initWithDatabase:(DatabaseController*)db;
- (void)stopCondition:(NSDictionary*)condition;
- (void)refreshState;

@end

NS_ASSUME_NONNULL_END
