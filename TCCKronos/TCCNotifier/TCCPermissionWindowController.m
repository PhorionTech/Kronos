
//  TCCPermissionWindowController.m
//  TCCKronos




#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "TCCPermissionWindowController.h"
#import "Bundle.h"

@implementation TCCPermissionWindowController {
    NSArray<Bundle*>* _bundles;
}

- (void)windowDidLoad {
    [[self window] setTitle:_application];
    [_appTitle setStringValue:_application];
    [_permissionTitle setStringValue:_permission];
    
    if (_applicationIcon) {
        [_imageView setImage:_applicationIcon];
    }
    
    _bundles = [Bundle bundlesFromIdentifier:self.bundleId];

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
- (IBAction)setRadioButton:(id)sender {
    NSButton* button = (NSButton*)sender;
    int buttonTag = button.tag;

    switch (buttonTag) {
        case 122:
            self.selectedCondition = @"time";
            break;
    }
}

- (IBAction)submitCondition:(id)sender {
    
    // The radio button that is currently selected
    // Beta version only includes time
    NSString* condition = @"time";
    // The value will be nil unless it's a time condition
    NSString* value = nil;
    NSString* identifier = nil;
    
    // Grab the time unit that the user has selected
    int intervalType = [_intervalType indexOfSelectedItem];

    NSDate *now = [NSDate date];
        
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];

    NSDate *newDate = [calendar dateByAddingComponents:componentsToAdd toDate:now options:0];
    
    _intervalFormatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [_intervalFormatter numberFromString:[_intervalValue stringValue]];
    
    // Only accept numbers
    if (number != nil) {
        
        int intValue = [number intValue];
        
        NSLog(@"%@ is a number.", number.description);
        
        switch (intervalType) {
            
            // 0 for Minutes
            case 0:
                [componentsToAdd setMinute:intValue];
                break;
            // 1 for Hours
            case 1:
                [componentsToAdd setHour:intValue];
                break;
            // 2 for Days
            case 2:
                [componentsToAdd setDay:intValue];
                break;
            // 3 for Weeks
            case 3:
                [componentsToAdd setDay:intValue*7];
                break;
            // 4 for Months
            case 4:
                [componentsToAdd setMonth:intValue];
                break;
            // 5 for Years
            case 5:
                [componentsToAdd setYear:intValue];
                break;

            default:
                NSLog(@"Invalid interval type");
                break;
        }
        
        NSDate *newDate = [calendar dateByAddingComponents:componentsToAdd toDate:now options:0];
        
        value = formatDateWithDate(newDate);

        
        [[XPCConnection shared] addCondition:condition withValue:value withIdentifier:identifier forService:self.permission forApp:self.bundleId];
        
        [self close];
    } else {
        NSLog(@"Invalid number provided.");
    }
}


@end
