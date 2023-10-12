
//  TCCEventWindowController.h
//  tcc-kronos




#import <Cocoa/Cocoa.h>

@interface TCCEventWindowController : NSWindowController

@property (strong) IBOutlet NSTextField *permissionLabel;
@property (strong) IBOutlet NSTextField *responsiblePID;
@property (strong) IBOutlet NSTextField *accessingPID;
@property (strong) IBOutlet NSTextField *requestingPID;

@property (strong) IBOutlet NSTextField *responsibleIdentifier;
@property (strong) IBOutlet NSTextField *accessingIdentifier;
@property (strong) IBOutlet NSTextField *requestingIdentifier;

@property (strong) NSDictionary* tccEvent;

@end
