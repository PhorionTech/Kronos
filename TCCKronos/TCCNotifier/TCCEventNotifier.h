
//  TCCEventNotifier.h
//  tcc-kronos




#import <Cocoa/Cocoa.h>
#import <UserNotifications/UserNotifications.h>

@interface TCCEventNotifier : NSObject

+(void) sendNotification:(NSString*)notificationTitle withSubtitle:(NSString*)notificationSubtitle;

@end
