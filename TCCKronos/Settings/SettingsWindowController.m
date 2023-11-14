
//  StartWindowController.m
//  TCCKronos




#import <Foundation/Foundation.h>
#import "SettingsWindowController.h"
#import "InstallExtension.h"
#import "XPCConnection.h"

#import "Utils.h"
#import "Constants.h"
#import "DispatchTimer.h"

#import "AppDelegate.h"

#define TOOLBAR_HEIGHT 44

@implementation SettingsWindowController {
    NSArray<NSButton*>* _viewButtons;
    NSFileManager* _fileManager;
    NSDictionary* _tagToSettingMap;
    NSView* _currentView;
    DispatchTimer* _viewRefresh;
    InstallExtension* _installExtension;
}


- (void)windowDidLoad {    
    _updater = [[((AppDelegate*)[[NSApplication sharedApplication] delegate]) updaterController] updater];

    _tagToSettingMap = @{
        @(301): SETTING_ESF,
        @(302): SETTING_SENTRY
    };
        
    _viewButtons = @[
        _setupButton,
        _aboutButton
    ];
    
    _fileManager = [NSFileManager defaultManager];
    _installExtension = [[InstallExtension alloc] init];

    
    // Check to see if the app is running for the first time
    // If so, open the welcome page
    
    static NSString* const hasRunAppOnceKey = @"hasRunAppOnceKey";
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:hasRunAppOnceKey] == NO)
    {
        // Some code you want to run on first use...
        [self loadViewWelcome];
        
        [defaults setBool:YES forKey:hasRunAppOnceKey];
    }
    else
    {
        [self loadViewSetup:nil];
    }
        
    _viewRefresh = [[DispatchTimer alloc]
        initWithInterval:2 * NSEC_PER_SEC
               tolorance:1 * NSEC_PER_SEC
                   queue:dispatch_get_main_queue()
                   block:^{
                    if (self->_currentView == self->_setupView) {
                            [self loadViewSetup:nil];
                        }
                   }];

    [_viewRefresh start];
}

- (IBAction)installSystemExtension:(id)sender {
    [_installExtension install];
    [self loadViewSetup:nil];
}

- (IBAction)configureFDA:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"]];
}

- (IBAction)configureLaunchDaemon:(id)sender {
    NSError* error = nil;

     NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
     NSString* appBundlePath = [resourcePath stringByDeletingLastPathComponent];
     NSURL* plist = [NSURL URLWithString:@"Contents/Library/LaunchAgents/io.phorion.kronos.plist"
                                 relativeToURL:[NSURL URLWithString:appBundlePath]];

     NSString* absolutePath = [plist absoluteString];

     NSString* targetPath = [@"~/Library/LaunchAgents/io.phorion.kronos.plist" stringByExpandingTildeInPath];

     if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath] == YES) {
         NSLog(@"Found existing plist at %@, deleting.", targetPath);

         [[NSFileManager defaultManager] removeItemAtPath:targetPath error:&error];

         if (error) {
             NSLog(@"An error occured: %@", [error localizedDescription]);
             return;
         }
     }

     if ([[NSFileManager defaultManager] isReadableFileAtPath:absolutePath]) {
         [[NSFileManager defaultManager] copyItemAtPath:absolutePath
                                                 toPath:targetPath
                                                  error:&error];

         if (error) {
             NSLog(@"An error occured: %@", [error localizedDescription]);
             return;
         }
     } else {
         NSLog(@"Couldn't find plist to copy at: %@", absolutePath);
         return;
     }
}

- (void)loadView:(NSView*)view toggleButton:(NSButton*)button
{
    [_contentView setSubviews:@[view]];
    
    [self.window setFrame:NSMakeRect(self.window.frame.origin.x, NSMaxY(self.window.frame) - view.frame.size.height - TOOLBAR_HEIGHT, view.frame.size.width, view.frame.size.height + TOOLBAR_HEIGHT) display:YES];
    
    for (NSButton* viewButton in _viewButtons) {
        if (viewButton == button) {
            [viewButton setState:NSControlStateValueOn];
        } else {
            [viewButton setState:NSControlStateValueOff];
        }
    }
    
    _currentView = view;
}

- (void)setStatusIcon:(NSImageView*)icon isValid:(BOOL)isValid
{
    if (isValid) {
        [icon setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
    } else {
        [icon setImage:[NSImage imageNamed:@"NSStatusUnavailable"]];
    }
}

- (IBAction)loadViewSetup:(id)sender {

    [self loadView:_setupView toggleButton:_setupButton];
    
    BOOL sysExtConnected = NO;
    
    if ([[XPCConnection shared] isConnected]) {
        [self setStatusIcon:_sysExtStatusIcon isValid:YES];
        sysExtConnected = YES;
    } else {
        [self setStatusIcon:_sysExtStatusIcon isValid:NO];
    }
    
    // Check to see if we have FDA by reading the TCC db
    if (!sysExtConnected) {
        // Can't check FDA if the Extension if it isn't connected
        [self setStatusIcon:_fdaStatusIcon isValid:NO];
    } else {
        // Make an XPC request to the extension to do a FDA check
        BOOL result = [[XPCConnection shared] checkFDA];
        
        [self setStatusIcon:_fdaStatusIcon isValid:result];
    }

    // Check to see if we have our launch daemon
    if ([_fileManager fileExistsAtPath:[LAUNCH_DEMON_PLIST stringByExpandingTildeInPath]]){
        [self setStatusIcon:_launchDaemonStatusIcon isValid:YES];
    } else {
        [self setStatusIcon:_launchDaemonStatusIcon isValid:NO];
    }
    
}

- (void)loadViewWelcome {
    [self loadView:_welcomeView toggleButton:nil];

}

- (IBAction)loadViewSettings:(id)sender {
    NSUserDefaults* appDefaults = [NSUserDefaults standardUserDefaults];
    
    for (NSNumber* key in _tagToSettingMap) {
        NSNumber* value = [appDefaults valueForKey:_tagToSettingMap[key]];
        
        if (value != nil) {
            NSButton* settingButton = [_settingsView viewWithTag:[key integerValue]];
            
            [settingButton setIntValue:[value boolValue]];
        }
    }
    
    [self loadView:_settingsView toggleButton:_settingsButton];
}

- (IBAction)loadViewAbout:(id)sender {
    [self loadView:_aboutView toggleButton:_aboutButton];
}

- (IBAction)toggleSetting:(NSButton*)sender {
    NSLog(@"Toggle setting '%@' to %d", [_tagToSettingMap objectForKey:@(sender.tag)], sender.intValue);
    [[NSUserDefaults standardUserDefaults] setObject:@(sender.intValue) forKey:[_tagToSettingMap objectForKey:@(sender.tag)]];
    [[XPCConnection shared] setAppDefaults:@(sender.intValue) forKey:[_tagToSettingMap objectForKey:@(sender.tag)]];
}

- (IBAction)toggleSparkleAutoUpdate:(id)sender {
    NSButton *checkbox = sender; // sender is the checkbox
       BOOL isChecked = (checkbox.state == NSControlStateValueOn);
       // Now, use Sparkle's SUUpdater to set your preference:
       [_updater setAutomaticallyChecksForUpdates:isChecked];
}

// on window close
// set activation policy
// Thank you Objective-See!
-(void)windowWillClose:(NSNotification *)notification
{
    //wait a bit, then set activation policy
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
    ^{
        //on main thread
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         
            //set activation policy
            [((AppDelegate*)[[NSApplication sharedApplication] delegate]) setActivationPolicy];
         
       });
        
    });
    
    return;
}

@end
