
//  ConnectionVerifier.h
//  TCCKronosExtension




#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

OSStatus SecTaskValidateForRequirement(SecTaskRef task, CFStringRef requirement);

@interface ConnectionVerifier : NSObject

+ (BOOL)isValid:(NSXPCConnection*)connection;

@end

NS_ASSUME_NONNULL_END
