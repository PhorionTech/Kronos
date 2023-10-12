
//  XPCExt.h
//  TCCKronosExtension




#import <Foundation/Foundation.h>
#import "XPCExtProtocol.h"

@class DatabaseController;
@class RevocationService;

NS_ASSUME_NONNULL_BEGIN

@interface XPCExt : NSObject <XPCExtProtocol>

- (instancetype)initWithUid:(uid_t)uid database:(DatabaseController*)db revocationService:(RevocationService*)revocationService;

@end

NS_ASSUME_NONNULL_END
