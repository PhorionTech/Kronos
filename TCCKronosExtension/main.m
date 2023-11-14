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
#include "SettingsReceiver.h"
#include "Constants.h"

@import Sentry;

int main(int argc, char *argv[])
{
    NSDictionary *appDefaults = @{
        SETTING_ESF: @YES,
        SETTING_SENTRY: @YES
    };

    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
#ifndef DEBUG
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_SENTRY]) {
        [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
            options.dsn = @"https://86f546f1a17194f700e2dd67d14fa3f4@o4505983381078016.ingest.sentry.io/4505985741357056";
            options.enableAppHangTracking = NO;
        }];
    }
#endif

    DatabaseController* db = [[DatabaseController alloc] init];
    
    RevocationService* revocationService = [[RevocationService alloc] initWithDatabase:db];
    UnifiedLogClient* unifiedLog = [[UnifiedLogClient alloc] init];
    
    XPCListener* xpc = [[XPCListener alloc] initWithDatabase:db revocationService:revocationService];
    ESFClient* esfClient = [[ESFClient alloc] initWithXPC:xpc];
    
    SettingsReceiver* settingsReceiver = [[SettingsReceiver alloc] init];
    [settingsReceiver setEsf:esfClient];
    
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
    
    NSArray* keysToObserve = @[
        SETTING_ESF,
        SETTING_SENTRY
    ];
    
    for (NSString* key in keysToObserve) {
        [[NSUserDefaults standardUserDefaults] addObserver:settingsReceiver
                                                forKeyPath:key
                                                   options:NSKeyValueObservingOptionNew
                                                   context:NULL];
    }

    

    dispatch_main();

    return 0;
}
