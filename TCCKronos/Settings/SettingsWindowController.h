
//  StartWindowController.h
//  tcc-kronos



@import Cocoa;

@interface SettingsWindowController : NSWindowController

@property (strong) IBOutlet NSView* contentView;
@property (strong) IBOutlet NSView* setupView;
@property (strong) IBOutlet NSView* settingsView;
@property (strong) IBOutlet NSView* aboutView;
@property (strong) IBOutlet NSView* welcomeView;

@property (strong) IBOutlet NSButton* setupButton;
@property (strong) IBOutlet NSButton* settingsButton;
@property (strong) IBOutlet NSButton* aboutButton;

@property (strong) IBOutlet NSImageView* sysExtStatusIcon;
@property (strong) IBOutlet NSImageView* fdaStatusIcon;
@property (strong) IBOutlet NSImageView* launchDaemonStatusIcon;

@end
