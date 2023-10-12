
//  TCCEventWindowController.m
//  TCCKronos




#import <Foundation/Foundation.h>
#import "TCCEventWindowController.h"
#import "AppDelegate.h"

@implementation TCCEventWindowController

- (void)windowDidLoad {
    
    
    _permissionLabel.stringValue = [_tccEvent valueForKey:@"service"];
    
    _responsiblePID.stringValue = [_tccEvent valueForKey:@"responsiblePid"];
    _responsibleIdentifier.stringValue = [_tccEvent valueForKey:@"responsibleIdentifier"];
    _requestingPID.stringValue = [_tccEvent valueForKey:@"requestingPid"];
    _requestingIdentifier.stringValue = [_tccEvent valueForKey:@"requestingIdentifier"];
    _accessingPID.stringValue = [_tccEvent valueForKey:@"accessingPid"];
    _accessingIdentifier.stringValue = [_tccEvent valueForKey:@"accessingIdentifier"];

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
    AppDelegate* appDelegate = [[NSApplication sharedApplication] delegate];
    [appDelegate setActivationPolicy];
            
        });
    });
}
@end
