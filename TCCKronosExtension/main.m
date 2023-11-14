#include <dispatch/dispatch.h>
#include <bsm/libbsm.h>
#include <stdio.h>
#include <os/log.h>

#include "XPC/XPCListener.h"
#include "UnifiedLogClient.h"
#include "DatabaseController.h"
#include "DispatchTimer.h"
#include "TCCHelper.h"
#include "TCCLog.h"
#include "ESFClient.h"
#include "RevocationService.h"

@import Sentry;

int main(int argc, char *argv[])
{
    [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
        options.dsn = @"https://86f546f1a17194f700e2dd67d14fa3f4@o4505983381078016.ingest.sentry.io/4505985741357056";
        options.enableAppHangTracking = NO;
     }];
    
    DatabaseController* db = [[DatabaseController alloc] init];
    
    RevocationService* revocationService = [[RevocationService alloc] initWithDatabase:db];
    UnifiedLogClient* unifiedLog = [[UnifiedLogClient alloc] init];
    
    XPCListener* xpc = [[XPCListener alloc] initWithDatabase:db revocationService:revocationService];
    ESFClient* esfClient = [[ESFClient alloc] initWithXPC:xpc];
    
    [unifiedLog startEventStream:^(TCCLog * _Nonnull log) {
         if ([log.type isEqualToString:@"REQUEST"] && ![log.function isEqualToString:@"TCCAccessRequest"]) {
             return;
         }

         [db writeTCCLogToDatabase:log];

         if ([log.type isEqualToString:@"AUTHREQ_PROMPTING"]) {
             [xpc sendPromptingNotification:@{
                 @"msgID": log.msgID
             }];
         }
    }];
    
    dispatch_main();

    return 0;
}
