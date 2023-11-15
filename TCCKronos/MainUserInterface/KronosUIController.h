
//  KronosUIController.h
//  tcc-kronos




#import "SettingsWindowController.h"
#import "XPCConnection.h"
#import "ApplicationUsageController.h"
#import "TCCPermissionWindowController.h"
#import "PermissionGrantController.h"

@import Cocoa;

@interface KronosUIController : NSWindowController <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (strong) IBOutlet NSTableHeaderView *tableHeader;

@property (strong) IBOutlet NSOutlineView *outlineView;
@property (strong) IBOutlet NSVisualEffectView *loadingSpinnerView;
@property (strong) IBOutlet NSProgressIndicator *loadingSpinner;

@property (strong) IBOutlet NSButton *grantsButton;
@property (strong) IBOutlet NSButton *permissionsButton;

@property (strong) IBOutlet NSView *contentsView;
@property (strong) IBOutlet NSView *permissionsView;
@property (strong) IBOutlet NSView *noGrantsView;

@property(nonatomic, retain)SettingsWindowController* settingsWindowController;
@property(nonatomic, retain)ApplicationUsageController* applicationUsageController;
@property(nonatomic, retain)TCCPermissionWindowController* tccPermissionWindowController;

@property BOOL dataLoaded;

@property (strong) IBOutlet NSSearchField *searchField;


@end
