
//  AppDelegate.h
//  tcc-kronos




#import <Cocoa/Cocoa.h>
#import "StatusBar.h"
#import "KronosUIController.h"
#import "SettingsWindowController.h"
#import "TCCNotifier/TCCEventWindowController.h"

@class XPCConnection;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property(strong) IBOutlet NSMenu *statusMenu;

@property(nonatomic, retain)StatusBar* statusBarController;
@property(nonatomic, retain)SettingsWindowController* settingsWindowController;
@property(nonatomic, retain)TCCEventWindowController* eventWindowController;
@property(nonatomic, retain)KronosUIController* kronosUIController;
@property XPCConnection* xpcConnection;
@property IBOutlet SPUStandardUpdaterController* updaterController;

-(void)setActivationPolicy;

@end

