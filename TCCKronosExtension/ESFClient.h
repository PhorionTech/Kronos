
//  ESFClient.h
//  TCCKronosExtension




#import <Foundation/Foundation.h>

@class XPCListener;

NS_ASSUME_NONNULL_BEGIN

@interface ESFClient : NSObject

- (instancetype)initWithXPC:(XPCListener*)xpc;

@end

NS_ASSUME_NONNULL_END
