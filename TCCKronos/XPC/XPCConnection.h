//
//  XPCConnection.h
//  TCCKronos
//
//  Created by Luke Roberts on 12/09/2023.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XPCConnection : NSObject <NSXPCListenerDelegate> {
}

@property (nonatomic, retain) NSXPCConnection* connection;

+ (id)shared;
- (void)registerWithExtension;
- (void)stopConnection;
- (BOOL)isConnected;

- (NSString*)checkSysExtVersion;
- (BOOL)checkFDA;
- (BOOL)retractTCCPermission:(NSString*)service withBundle:(NSString*)bundleId;
- (NSArray<NSDictionary*>*)tccSelectAll;
- (NSDictionary*)tccSelectRecordByClient:(NSString*)client service:(NSString*)service;
- (NSDictionary*)dbConditionsForService:(NSString*)service forApp:(NSString*)appIdentifier;
- (BOOL)addCondition:(NSString*)condition withValue:(NSString*)value withIdentifier:(NSString*)identifier forService:(NSString*)service forApp:(NSString*)app;
- (NSArray<NSDictionary*>*)dbUsageForApp:(NSString*)appIdentifier;
- (NSDictionary*)getUsageByMsgID:(NSString*)msgID;
- (NSArray<NSDictionary*>*)getConditions;
- (void)setAppDefaults:(id)value forKey:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
