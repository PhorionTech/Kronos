
//  XPCListener.h
//  TCCKronosExtension




#import <Foundation/Foundation.h>

@class TCCLog;
@class DatabaseController;
@class RevocationService;

NS_ASSUME_NONNULL_BEGIN

@interface XPCListener : NSObject <NSXPCListenerDelegate>

@property (nonatomic, retain) NSXPCConnection* connection;
@property (nonatomic, retain) NSXPCListener* listener;

- (id)initWithDatabase:(DatabaseController*)db revocationService:(RevocationService*)revocationService;
- (void)sendPromptingNotification:(NSDictionary*)log;
- (void)sendTamperingNotification:(NSDictionary*)tamperInformation;
- (void)sendRevokeNotification:(NSDictionary*)info;

@end

NS_ASSUME_NONNULL_END
