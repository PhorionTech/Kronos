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
#ifndef DEBUG
    [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
         options.dsn = @"https://86f546f1a17194f700e2dd67d14fa3f4@o4505983381078016.ingest.sentry.io/4505985741357056";
     }];
#endif
    
    DatabaseController* db = [[DatabaseController alloc] init];
    
    RevocationService* revocationService = [[RevocationService alloc] initWithDatabase:db];
    UnifiedLogClient* unifiedLog = [[UnifiedLogClient alloc] init];
    
    XPCListener* xpc = [[XPCListener alloc] initWithDatabase:db revocationService:revocationService];
    ESFClient* esfClient = [[ESFClient alloc] initWithXPC:xpc];
    
    DispatchTimer* unifiedLogTimer = [[DispatchTimer alloc]
        initWithInterval:1 * NSEC_PER_SEC
               tolorance:1 * NSEC_PER_SEC
                   queue:dispatch_get_main_queue()
                   block:^{
                        [unifiedLog retrieveLatestEvents:^(TCCLog * _Nonnull log) {
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
                   }];

    [unifiedLogTimer start];
    

    dispatch_main();

    return 0;
}
