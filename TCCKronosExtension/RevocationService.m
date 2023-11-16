
//  RevocationService.m
//  tcc-kronos




#import "RevocationService.h"

#import "DatabaseController.h"
#import "TCCHelper.h"
#import "TCCUtilHelper.h"
#import "Constants.h"
#import "Bundle.h"
#import "TCCEventNotifier.h"

@implementation RevocationService {
    DatabaseController* _db;
    NSMutableDictionary* _trackedConditions;
}

- (instancetype)initWithDatabase:(DatabaseController*)db
{
    self = [super init];
    if (self) {
        _db = db;
        _trackedConditions = [NSMutableDictionary dictionary];
        
        [self refreshState];
    }
    return self;
}

- (void)refreshState {
    NSArray<NSDictionary*>* conditions = [_db getConditions];
    
    for (NSMutableDictionary* condition in conditions) {
        [self stopCondition:condition];
        
        if ([condition[@"conditionType"] isEqualToString:@"time"]) {
            [self handleTimeCondition:condition];
        }
    }
}

- (void)stopCondition:(NSDictionary*)condition {
    NSDictionary* needle = [_trackedConditions objectForKey:condition[@"uuid"]];
    if (needle != nil) {
        [_trackedConditions removeObjectForKey:condition[@"uuid"]];

        if ([needle[@"conditionType"] isEqualToString:@"time"]) {
            dispatch_source_cancel(needle[@"timer"]);
        }
        
    }
}

- (void)revocationCompletionHandler:(NSDictionary*)condition
{
    // Check if authValue is still 2
    TCCHelper* tccHelper = [TCCHelper shared];
    [tccHelper refresh];
    
    NSDictionary* needle = [tccHelper selectRecordByClient:condition[@"appIdentifier"] service:condition[@"service"]];
    
    if ([needle[@"auth_value"] integerValue] != 2) {
        NSLog(@"App no longer has access. We ain't touching that.");
        [_db deleteCondition:condition];
        [self stopCondition:condition];
        return;
    }
    
    BOOL result;
    
    // Check where it came from
    if ([needle[@"source"] isEqualToString:@"userTCCDatabase"]) {
        result = [tccHelper resetDBPermissions:condition[@"service"] forClient:condition[@"appIdentifier"]];
    } else if ([needle[@"source"] isEqualToString:@"systemTCCDatabase"]) {
        result = [TCCUtilHelper runTCCUtil:condition[@"service"] withBundle:condition[@"appIdentifier"]];
    } else {
        NSLog(@"Source is not known...");
    }
    
    [TCCEventNotifier sendNotification:@"Permission Revoked" withSubtitle:[NSString stringWithFormat:@"Service %@ was revoked for %@ for %@ condition.", condition[@"service"], condition[@"appIdentifier"], condition[@"conditionType"]]];
    
    [_db deleteCondition:condition];
    [self stopCondition:condition];
}

- (void)handleVersionCondition:(NSMutableDictionary*)condition {
//    NSString* targetVersion = condition[@"conditionValue"];
    
//    Bundle* bundle = [Bundle bundlesFromIdentifier:condition[@"appIdentifier"]];

//    if (bundle == nil || [targetVersion isNotEqualTo:[[[bundle bundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]) {
//        [self revocationCompletionHandler:condition];
//    }
}

- (void)handleTimeCondition:(NSMutableDictionary*)condition {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(timer, ^{
        [self revocationCompletionHandler:condition];
    });
    
    NSString* dateString = condition[@"conditionValue"];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDate* date = [dateFormatter dateFromString:dateString];
    NSDate* now = [NSDate now];
    
    NSTimeInterval secondsBetween = [date timeIntervalSinceDate:now];
    
    if (secondsBetween < 0) {
        secondsBetween = 1;
    }
       
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, secondsBetween * NSEC_PER_SEC), 0, 10 * NSEC_PER_SEC);
    dispatch_resume(timer);
    
    [condition setObject:timer forKey:@"timer"];
    
    [_trackedConditions setObject:condition forKey:condition[@"uuid"]];
}

@end
