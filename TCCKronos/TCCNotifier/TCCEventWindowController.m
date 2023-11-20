
//  TCCEventWindowController.m
//  TCCKronos




#import <Foundation/Foundation.h>
#import "TCCEventWindowController.h"
#import "AppDelegate.h"

@implementation TCCEventWindowController

- (void)windowDidLoad {
    
    // Set window level to be always in front
    [[self window] setLevel:NSFloatingWindowLevel];
    
    NSString *service = [_tccEvent valueForKey:@"service"];
    _permissionLabel.stringValue = (service != nil && [service isNotEqualTo:@""]) ? service : @"N/A";

    NSString *responsiblePid = [_tccEvent valueForKey:@"responsiblePid"];
    _responsiblePID.stringValue = (responsiblePid != nil && [responsiblePid isNotEqualTo:@""]) ? responsiblePid : @"N/A";

    NSString *responsibleIdentifier = [_tccEvent valueForKey:@"responsibleIdentifier"];
    _responsibleIdentifier.stringValue = (responsibleIdentifier != nil && [responsibleIdentifier isNotEqualTo:@""]) ? responsibleIdentifier : @"N/A";

    NSString *requestingPid = [_tccEvent valueForKey:@"requestingPid"];
    _requestingPID.stringValue = (requestingPid != nil && [requestingPid isNotEqualTo:@""]) ? requestingPid : @"N/A";

    NSString *requestingIdentifier = [_tccEvent valueForKey:@"requestingIdentifier"];
    _requestingIdentifier.stringValue = (requestingIdentifier != nil && [requestingIdentifier isNotEqualTo:@""]) ? requestingIdentifier : @"N/A";

    NSString *accessingPid = [_tccEvent valueForKey:@"accessingPid"];
    _accessingPID.stringValue = (accessingPid != nil && [accessingPid isNotEqualTo:@""]) ? accessingPid : @"N/A";

    NSString *accessingIdentifier = [_tccEvent valueForKey:@"accessingIdentifier"];
    _accessingIdentifier.stringValue = (accessingIdentifier != nil && [accessingIdentifier isNotEqualTo:@""]) ? accessingIdentifier : @"N/A";

}

//on window close
// set activation policy
-(void)windowWillClose:(NSNotification *)notification
{
    [self callActivationPolicy];
    return;
}

-(void) callActivationPolicy{
    //wait a bit, then set activation policy
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
    ^{
        //on main thread
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    // Set the app delegate so there is no dock icon etc.
    AppDelegate* appDelegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
    [appDelegate setActivationPolicy];
            
        });
    });
}
@end
