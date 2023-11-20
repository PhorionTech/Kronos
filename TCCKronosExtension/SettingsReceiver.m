//
//  SettingsReceiver.m
//  TCCKronosExtension
//
//  Created by dev on 14/11/2023.
//

#import "SettingsReceiver.h"
#import "Constants.h"
#import "ESFClient.h"

@import Sentry;

@implementation SettingsReceiver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:SETTING_ESF]) {
        if ([object boolForKey:keyPath]) {
            [self.esf start];
        } else {
            [self.esf stop];
        }
    } else if ([keyPath isEqualToString:SETTING_SENTRY]) {
#ifndef DEBUG
        if ([object boolForKey:keyPath]) {
            [SentrySDK startWithConfigureOptions:^(SentryOptions * _Nonnull options) {
                options.dsn = @"";
            }];
        } else {
            [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
                options.dsn = @"https://86f546f1a17194f700e2dd67d14fa3f4@o4505983381078016.ingest.sentry.io/4505985741357056";
                options.enableAppHangTracking = NO;
            }];
        }
#endif
    }
}
 
@end
