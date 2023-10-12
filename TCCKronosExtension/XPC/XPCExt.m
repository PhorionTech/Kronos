
//  XPCExt.m
//  TCCKronosExtension





#import "XPCExt.h"
#import "UnifiedLogClient.h"
#import "TCCUtilHelper.h"
#import "../DatabaseController.h"
#import "TCCHelper.h"
#import "RevocationService.h"

#include <pwd.h>
#import <dlfcn.h>

@implementation XPCExt {
    TCCHelper* _tccHelper;
    DatabaseController* _db;
    RevocationService* _revocationService;
}

- (instancetype)initWithUid:(uid_t)uid database:(DatabaseController*)db revocationService:(RevocationService*)revocationService {
    self = [super init];
    if (self) {
        _db = db;
        _revocationService = revocationService;
        
        _tccHelper = [TCCHelper shared];
    }
    return self;
}

- (void)checkFDAWithReply:(void (^)(BOOL))reply {
    int fd = open([@"/Library/Application Support/com.apple.TCC/TCC.db" cStringUsingEncoding:NSUTF8StringEncoding], O_RDONLY);
    
    if (fd != -1) {
        close(fd);
        reply(YES);
    } else {
        reply(NO);
    }
}

- (void)tccSelectAllWithReply:(void (^)(NSArray<NSDictionary*>*))reply {
    reply([_tccHelper selectAll]);
}

- (void)tccSelectRecordByClient:(NSString*)client service:(NSString*)service withReply:(void (^)(NSDictionary*))reply {
    reply([_tccHelper selectRecordByClient:client service:service]);
}

- (void)retractTCCPermission:(NSString*)service withBundle:(NSString*)bundleId withReply:(nonnull void (^)(BOOL))reply{
        
    // Do revoky things
    
    reply(YES);
}

- (void)dbConditionsForService:(nonnull NSString *)service forApp:(nonnull NSString *)appIdentifier withReply:(nonnull void (^)(NSDictionary * _Nonnull))reply {
    reply([_db getConditionsForService:service forApp:appIdentifier]);
}


- (void)dbUsageForApp:(nonnull NSString *)appIdentifier withReply:(nonnull void (^)(NSArray<NSDictionary *> * _Nonnull))reply {
    reply([_db getUsageForApp:appIdentifier]);
}

- (void)getUsageByMsgID:(NSString*)msgID withReply:(void (^)(NSDictionary*))reply {
    reply([_db getUsageByMsgID:msgID]);
}

- (void)addCondition:(NSString*)condition withValue:(NSString*)value withIdentifier:(NSString*)identifier forService:(NSString*)service forApp:(NSString*)app withReply:(void (^)(BOOL))reply {
    
    NSDictionary* conditionsForService = [_db getConditionsForService:service forApp:app];
    
    if (conditionsForService != nil) {
        // Stop activity if we have one
        [_revocationService stopCondition:conditionsForService];
        
        // Delete existing
        [_db deleteCondition:conditionsForService];
    }
        
    BOOL result = [_db addCondition:condition withValue:value withIdentifier:identifier forService:service forApp:app];
    
    [_revocationService refreshState];
    
    reply(result);
}

- (void)getConditionsWithReply:(nonnull void (^)(NSArray<NSDictionary *> * _Nonnull))reply {
    reply([_db getConditions]);
}

- (void)doRegister {
    NSLog(@"First method called!");
}


@end
