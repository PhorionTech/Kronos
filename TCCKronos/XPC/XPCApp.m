
//  XPCApp.m
//  TCCKronos




#import "XPCApp.h"
#import "XPCConnection.h"
#import "TCCEventNotifier.h"

@implementation XPCApp

- (void)promptingNotification:(NSDictionary*)log {
    NSDictionary* result = [[XPCConnection shared] getUsageByMsgID:log[@"msgID"]];
   
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.tccEventWindowController = [[TCCEventWindowController alloc] initWithWindowNibName:@"TCCEventWindow"];
        
        [self.tccEventWindowController setTccEvent:result];
        
        [self.tccEventWindowController showWindow:self];
        
    });

}

- (void)tamperingNotification:(NSDictionary*)tamperInformation {
    NSString* subtitle = [NSString stringWithFormat:@"The following PID was responsible: %@", [tamperInformation valueForKey:@"pid"]];
    [TCCEventNotifier sendNotification:@"User TCC.db tampering detected" withSubtitle:subtitle];
    NSLog(@"Recieved a tampering notification!");
}

- (void)revokeNotification:(NSDictionary*)revokeInformation {
    NSLog(@"Recieved a revoke notification");
}

@end
