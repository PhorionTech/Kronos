
//  XPCAppProtocol.h
//  tcc-kronos




#import <Foundation/Foundation.h>
#import "TCCLog.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XPCAppProtocol <NSObject>

- (void)promptingNotification:(NSDictionary*)log;
- (void)tamperingNotification:(NSDictionary*)tamperInformation;
- (void)revokeNotification:(NSDictionary*)revokeInformation;

@end

NS_ASSUME_NONNULL_END
