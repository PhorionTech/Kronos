
//  TCCEventNotifier.m
//  TCCKronos




#import <Foundation/Foundation.h>
#import "TCCEventNotifier.h"

@implementation TCCEventNotifier

+(void) sendNotification:(NSString*)notificationTitle withSubtitle:(NSString*)notificationSubtitle {
    
    //notification content
    UNMutableNotificationContent* content = nil;
    
    //notificaiton request
    UNNotificationRequest* request = nil;

    content = [[UNMutableNotificationContent alloc] init];
    
    content.title = notificationTitle;
    content.subtitle = notificationSubtitle;

    request = [UNNotificationRequest requestWithIdentifier:NSUUID.UUID.UUIDString content:content trigger:NULL];
    //send notification
    [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error)
    {
        //error?
        if(nil != error)
        {
            //err msg
            NSLog(@"Error requesting notifications.");
        }
    }];
}
@end
