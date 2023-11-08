
//  TCCPermissionWindowController.h
//  tcc-kronos




#import <Cocoa/Cocoa.h>

@interface TCCPermissionWindowController : NSWindowController

@property (strong) IBOutlet NSImageView *imageView;
@property (strong) NSString* selectedCondition;

@property (strong) NSString* application;
@property (strong) NSString* bundleId;
@property (strong) NSImage* applicationIcon;
@property (strong) NSString* permission;
@property (strong) IBOutlet NSTextField *appTitle;
@property (strong) IBOutlet NSTextField *permissionTitle;
@property (strong) IBOutlet NSTextField *intervalValue;
@property (strong) IBOutlet NSPopUpButton *intervalType;
@property (strong) IBOutlet NSNumberFormatter *intervalFormatter;

@end
