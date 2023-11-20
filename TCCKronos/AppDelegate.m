//
//  AppDelegate.m
//  tcc-kronos
//
//  Created by Calum Hall on 08/09/2023.
//

#import "AppDelegate.h"

#import "DispatchTimer.h"
#import "XPCConnection.h"
#import "TCCNotifier/TCCEventNotifier.h"
#import "ExtensionToggling/InstallExtension.h"

#import "Constants.h"
#import "Hasher.h"

@import Sentry;

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;

@end

@implementation AppDelegate {
    DispatchTimer* _xpcConnectRetry;
    InstallExtension* _installExtension;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Register a default set of values for UserDefaults
    NSDictionary *appDefaults = @{
        SETTING_ESF: @YES,
        SETTING_SENTRY: @YES
    };

    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
#ifndef DEBUG
    if ([[[NSBundle mainBundle] bundlePath] hasPrefix:@"/Applications"] == NO) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"App must be run from /Applications, please install the app and relaunch."];
        [alert setAlertStyle:NSAlertStyleInformational];

        [alert runModal];
     
        [[NSApplication sharedApplication] terminate:self];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_SENTRY]) {
        [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
             options.dsn = @"https://66f5a9a33d681719cc93df3fd8c3e10f@o4505983381078016.ingest.sentry.io/4505983385075712";
         }];
    }
#endif
    
    _statusBarController = [[StatusBar alloc] init:self.statusMenu];
    
    // Open the settings window on the app's first launch
    static NSString* const hasRunAppOnceKey = @"hasRunAppOnceKey";
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:hasRunAppOnceKey] == NO)
    {
        self.settingsWindowController = [[SettingsWindowController alloc] initWithWindowNibName:@"SettingsWindow"];
        [self.settingsWindowController showWindow:self];
    }
    
    // Setup the XPC Connection to our system extension
    _xpcConnection = [XPCConnection shared];
    
    if ([_xpcConnection isConnected]) {
        NSString* sysExtVersion = [_xpcConnection checkSysExtVersion];
        
        if ([sysExtVersion isNotEqualTo:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]) {
            // Version mismatch between sysext and app, we should install.
            
            _installExtension = [[InstallExtension alloc] init];
            [_installExtension install];
        }
    }
    
    // Check to see if the hash of any installed launch items matches the one in the bundle
    [self checkLaunchdPlist];
    
    _xpcConnectRetry = [[DispatchTimer alloc]
        initWithInterval:2 * NSEC_PER_SEC
               tolorance:1 * NSEC_PER_SEC
                   queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                   block:^{
                        if ([self->_xpcConnection isConnected] == NO) {
                            [self->_xpcConnection registerWithExtension];
                        }
                   }];

    [_xpcConnectRetry start];

    [self requestNotifications];
    
    // Set the activation policy to NSApplicationActivationPolicyAccessory when the app starts
    [self setActivationPolicy];
    
    NSArray* keysToObserve = @[
        SETTING_SENTRY
    ];
    
    for (NSString* key in keysToObserve) {
        [[NSUserDefaults standardUserDefaults] addObserver:self
                                                forKeyPath:key
                                                   options:NSKeyValueObservingOptionNew
                                                   context:NULL];
    }
}

- (void)checkLaunchdPlist {
     NSError* error = nil;

     NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
     NSString* appBundlePath = [resourcePath stringByDeletingLastPathComponent];
     NSURL* plist = [NSURL URLWithString:@"Contents/Library/LaunchAgents/io.phorion.kronos.plist"
                                 relativeToURL:[NSURL URLWithString:appBundlePath]];

     NSString* absolutePath = [plist absoluteString];

     NSString* targetPath = [@"~/Library/LaunchAgents/io.phorion.kronos.plist" stringByExpandingTildeInPath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath] == YES) {
        if ([[Hasher calculateSHA256ForFileAtPath:targetPath] isEqualToString:[Hasher calculateSHA256ForFileAtPath:absolutePath]]) {
            return;
        }
        
        NSLog(@"Found existing plist at %@", targetPath);
        
        [[NSFileManager defaultManager] removeItemAtPath:targetPath error:&error];
        
        if (error) {
            NSLog(@"An error occured: %@", [error localizedDescription]);
            return;
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
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if ([keyPath isEqualToString:SETTING_SENTRY]) {
#ifndef DEBUG
        if ([object boolForKey:keyPath]) {
            [SentrySDK startWithConfigureOptions:^(SentryOptions * _Nonnull options) {
                options.dsn = @"";
            }];
        } else {
            [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
                options.dsn = @"https://66f5a9a33d681719cc93df3fd8c3e10f@o4505983381078016.ingest.sentry.io/4505983385075712";
            }];
        }
#endif
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}
- (IBAction)openSettings:(id)sender {
    
    
    if (self.settingsWindowController == nil) {
        self.settingsWindowController = [[SettingsWindowController alloc] initWithWindowNibName:@"SettingsWindow"];
    }
    else {
        NSLog(@"The settings window has already been allocated");
    }
    [self.settingsWindowController showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
    
    // Once the window has loaded, we change the activation policy
    [self setActivationPolicy];
}

- (IBAction)openKronos:(id)sender {
    if (self.kronosUIController == nil) {
        self.kronosUIController = [[KronosUIController alloc] initWithWindowNibName:@"KronosUI"];
    }
    else {
        NSLog(@"The KronosUI window has already been allocated");
    }
    [self.kronosUIController showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
    
    // Once the window has loaded, we change the activation policy
    [self setActivationPolicy];
}

- (IBAction)quitApp:(id)sender {
    // Seeya
    [NSApplication.sharedApplication terminate:self];
}


-(void)requestNotifications {
    // Request notifications if they are not already authorised
    [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error)
    {
        if(error) {
            NSLog(@"Error requesting notification authorisation");
        }
        else if (!granted){
            NSLog(@"Notifications aren't enabled");
        }
    }];
}

// Thank you Objective-See for the setActivationPolicy behaviour!
-(void)setActivationPolicy
{
    //visible window
    BOOL visibleWindow = NO;
    
    //find any visible windows
    for(NSWindow* window in NSApp.windows)
    {
        //ignore status bar
        if(YES == [window.className isEqualToString:@"NSStatusBarWindow"])
        {
            //skip
            continue;
        }
        
        //visible?
        if(YES == window.isVisible)
        {
            //set flag
            visibleWindow = YES;
            
            //done
            break;
        }
    }
    
    //any windows?
    //bring app to foreground
    if(YES == visibleWindow)
    {
        //foreground
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    }
    
    //no more windows
    // send app to background
    else
    {
        //background
        [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    }
    
    return;
}

- (BOOL)supportsGentleScheduledUpdateReminders {
    return YES;
}

- (void)standardUserDriverWillHandleShowingUpdate:(BOOL)handleShowingUpdate forUpdate:(SUAppcastItem *)update state:(SPUUserUpdateState *)state {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    
    if (!state.userInitiated) {
        // Set a badge number on the app's Dock tile
        [NSApp.dockTile setBadgeLabel:@"1"];
    }
}

- (void)standardUserDriverDidReceiveUserAttentionForUpdate:(SUAppcastItem *)update {
    [NSApp.dockTile setBadgeLabel:@""];
}

- (void)standardUserDriverWillFinishUpdateSession {
    [self setActivationPolicy];
}



@end
