
//  XPCExtProtocol.h
//  tcc-kronos




#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XPCExtProtocol <NSObject>

- (void)checkFDAWithReply:(void (^)(BOOL))reply;
- (void)retractTCCPermission:(NSString*)service withBundle:(NSString*)bundleId withReply:(void (^)(BOOL))reply;
- (void)tccSelectAllWithReply:(void (^)(NSArray<NSDictionary*>*))reply;
- (void)tccSelectRecordByClient:(NSString*)client service:(NSString*)service withReply:(void (^)(NSDictionary*))reply;
- (void)dbConditionsForService:(NSString*)service forApp:(NSString*)appIdentifier withReply:(void (^)(NSDictionary*))reply;
- (void)dbUsageForApp:(NSString*)appIdentifier withReply:(void (^)(NSArray<NSDictionary*>*))reply;
- (void)addCondition:(NSString*)condition withValue:(NSString*)value withIdentifier:(NSString*)identifier forService:(NSString*)service forApp:(NSString*)app withReply:(void (^)(BOOL))reply;
- (void)getUsageByMsgID:(NSString*)msgID withReply:(void (^)(NSDictionary*))reply;
- (void)getConditionsWithReply:(nonnull void (^)(NSArray<NSDictionary *> * _Nonnull))reply;
- (void)doRegister;

@end

NS_ASSUME_NONNULL_END
