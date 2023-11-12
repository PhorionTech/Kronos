
//  KronosUIController.m
//  TCCKronos




#import <Foundation/Foundation.h>

#import "KronosUIController.h"
#import "AppDelegate.h"
#import "Bundle.h"
#import "Signing.h"

#import "Utils.h"

@implementation KronosUIController {
    NSArray* _tccPermissions;
    NSMutableArray* _sortedPermissions;
    NSMutableArray* _unfilteredPermissions;
    NSArray* _permissionsByApp;
}

- (void)windowDidLoad {
    
    [_searchField setAction:@selector(searchFieldDidChange:)];

    _tccPermissions = [[XPCConnection shared] tccSelectAll];
    
    self.tableHeader = nil;

    [self loadGrants:nil];
    
    [_outlineView setTarget:self];
    [_outlineView setAction:@selector(outlineViewClicked:)];
    [_outlineView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    
    _loadingSpinnerView.wantsLayer = YES;
    _loadingSpinnerView.layer.cornerRadius = 20.0;
    [_loadingSpinnerView setMaterial:NSVisualEffectMaterialSidebar];

    
    //wait a bit, then set activation policy
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
    ^{
        //on main thread
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sortTCCPermissions];
            
            // Once the permissions have been loaded refresh the outline view
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                    [self.outlineView beginUpdates];
                    [self.outlineView reloadData];
                    [self.outlineView endUpdates];
                    
                    self.loadingSpinnerView.hidden = YES;
                    self.dataLoaded = YES;
                });
            });
            
        });
    });
    
}

//on window close
// set activation policy
-(void)windowWillClose:(NSNotification *)notification
{
    // Tidy the place up
    [_outlineView collapseItem:nil];
    [self callActivationPolicy];
    return;
}

- (IBAction)loadGrants:(id)sender {
    
    NSArray<NSDictionary*>* currentGrants = [[XPCConnection shared] getConditions];
    if ([currentGrants count] == 0 ) {
        // Load up the no grants view
        [_contentsView setSubviews:@[_noGrantsView]];
    }
    else {
        // Load up the table view
        PermissionGrantController* myGrantViewController = [[PermissionGrantController alloc] initWithNibName:@"PermissionGrantView" bundle:nil];
        myGrantViewController.currentGrants = currentGrants;
        [_contentsView setSubviews:@[[myGrantViewController view]]];
    }
    
}

- (IBAction)loadPermissions:(id)sender {
    
    [_contentsView setSubviews:@[_permissionsView, _loadingSpinnerView]];
    
    if (!self.dataLoaded) {
        _loadingSpinnerView.hidden = NO;
        [_loadingSpinner startAnimation:nil];
    }
}

- (IBAction)refreshPermissions:(id)sender {
    
    _tccPermissions = [[XPCConnection shared] tccSelectAll];
    
    _loadingSpinnerView.hidden = NO;
    [_loadingSpinner startAnimation:nil];
    
    //fully pull and sort the permissions
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
    ^{
        //on main thread
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sortTCCPermissions];
            
            // Once the permissions have been loaded refresh the outline view
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                    [self.outlineView beginUpdates];
                    [self.outlineView reloadData];
                    [self.outlineView endUpdates];
                    
                    self.loadingSpinnerView.hidden = YES;
                    self.dataLoaded = YES;
                });
            });
            
        });
    });
}


- (IBAction)loadSettings:(id)sender {
    
    if (self.settingsWindowController == nil) {
        self.settingsWindowController = [[SettingsWindowController alloc] initWithWindowNibName:@"SettingsWindow"];
    }
    else {
        NSLog(@"The settings window has already been allocated");
    }
    [self.settingsWindowController showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
}

-(NSMutableArray*)sortTCCPermissions {
    
    _sortedPermissions = [NSMutableArray new];
    
    NSArray *apps = [_tccPermissions valueForKeyPath:@"@distinctUnionOfObjects.client"];
    for (NSString *appId in apps)
    {
        NSMutableArray *entry = [NSMutableArray new];
        NSMutableDictionary *appEntry = [NSMutableDictionary new];
        Bundle* target = [self getBundle:appId];

        NSArray *appNames = [_tccPermissions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"client = %@", appId]];
        for (int i = 0; i < appNames.count; i++)
        {
            NSString *name = [appNames objectAtIndex:i];
            [entry addObject:name];
        }
        
        [appEntry setObject:appId forKey:@"app_name"];
        [appEntry setObject:appId forKey:@"app_client"];
        [appEntry setObject:entry forKey:@"app_permissions"];
        if (target) {
            if (target.name != nil){
                [appEntry setValue:target.name forKey:@"app_name"];
            }
            [appEntry setObject:target forKey:@"app_bundle"];
        }
        [_sortedPermissions addObject:appEntry];
        
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"app_name" ascending:YES];
    [_sortedPermissions sortUsingDescriptors:@[sortDescriptor]];
    
    // We want to keep a replica to revert back to after filtering
    _unfilteredPermissions = _sortedPermissions;
    return _sortedPermissions;
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


-(Bundle*) getBundle:(NSString*)appIdentifier{

    Bundle* target = nil;
    
    if ([appIdentifier hasPrefix:@"/"]) {
        // Treat as a path, can pull the type from the db to do this better...
        target = [Bundle bundleFromBinaryPath:appIdentifier];
    } else {
        NSArray<Bundle*>* bundlesForIdentifier = [Bundle bundlesFromIdentifier:appIdentifier];
    
        for (Bundle* bundle in bundlesForIdentifier) {
            if (bundle.icon != nil) {
                target = bundle;
            }
        }
    }
    return target;
}

// number of applications to be listed
-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    // root item, return number of apps
    if (item == nil) {
        return [_sortedPermissions count];
    }
    else {
        return [[item valueForKey:@"app_permissions"] count];
    }
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    // We only want to expand the root items, which contain app_name, app_permissions and maybe app_bundle
    return ([item count] <= 4);
}

//return child
-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
        return [_sortedPermissions objectAtIndex:index];
    } else {
        return [[item valueForKey:@"app_permissions"] objectAtIndex:index];
    }
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSImage* defaultIcon = [[NSWorkspace sharedWorkspace]
                                    iconForFileType: NSFileTypeForHFSTypeCode(kGenericApplicationIcon)];
                            
    [defaultIcon setSize:NSMakeSize(128, 128)];
    
    if (tableColumn == self.outlineView.tableColumns[0]) {
        if([item valueForKey:@"app_name"]) {
            // Root (App)
            NSTableCellView *cell = [outlineView makeViewWithIdentifier:@"appCell" owner:nil];
            NSImageView* appIcon = [cell viewWithTag:109];
            NSImageView* signedIcon = [cell viewWithTag:187];
            
            [signedIcon setImage:nil];
            [appIcon setImage:defaultIcon];
            cell.textField.stringValue = [item valueForKey:@"app_name"];
            
            Bundle* target = [item valueForKey:@"app_bundle"];
            
            if (target != nil) {
                
                [appIcon setImage:target.icon];
                NSDictionary* signingInfo = [target signingInfo];
                
                // src: https://github.com/objective-see/LuLu/blob/4136b68d40f01e64d6d9f68f875391782c308e4d/LuLu/App/SigningInfoViewController.m
                switch ([signingInfo[KEY_CS_STATUS] integerValue]) {
                    case noErr:
                        // Signed
                        
                        [signedIcon setImage:[NSImage imageNamed:@"blue-lock"]];
                        
                        if ([signingInfo[KEY_CS_SIGNER] intValue] == Apple) {
                            [signedIcon setToolTip:@"Signed by Apple"];

                        } else {
                            [signedIcon setToolTip:signingInfo[KEY_CS_AUTHS][0]];
                        }
                        
                        break;
                    case errSecCSUnsigned:
                        // Unsigned
                        [signedIcon setImage:[NSImage imageNamed:@"orange-lock"]];
                        break;
                    default:
                        // Signing error
                        break;
                }
            } else {
                
                [signedIcon setImage:[NSImage imageNamed:@"question-icon"]];
                [signedIcon setToolTip:@"Bundle not found on disk"];
            }
       
            [((NSButton*)[cell viewWithTag:104]) setAction:@selector(openAppUsage:)];
            
            return cell;
        }
        else {
            // Child (permissions)
            NSTableCellView *cell = [outlineView makeViewWithIdentifier:@"permissionCell" owner:nil];
            
            NSString* last_modified = formatDateWithNumber([item valueForKey:@"last_modified"]);
            
            // Permission name
            ((NSTextField*)[cell viewWithTag:100]).stringValue = [item valueForKey:@"service"];
            ((NSTextField*)[cell viewWithTag:101]).stringValue = [item valueForKey:@"auth_value"];
            ((NSTextField*)[cell viewWithTag:102]).stringValue = [item valueForKey:@"auth_reason"];
            ((NSTextField*)[cell viewWithTag:103]).stringValue = last_modified;
            [((NSButton*)[cell viewWithTag:106]) setAction:@selector(createCondition:)];


            return cell;
        }
    }
    else {
        return nil;
    }

    
    
}

- (IBAction)outlineViewClicked:(id)sender {
    NSDictionary* selectedRow = [self.outlineView itemAtRow:self.outlineView.selectedRow];
    
    // Expand parent row
    if ([selectedRow count] <= 4) {
        // toggle expand
        if ([self.outlineView isItemExpanded:selectedRow]) {
            [self.outlineView collapseItem:selectedRow];
        } else {
            [self.outlineView expandItem:selectedRow];
        }
    }
    // Open condition build for child rows
    else {
        [self createCondition:selectedRow];
    }
}

- (void)searchFieldDidChange:(NSSearchField *)searchField {
    [self refreshOutlineView];
}

- (void)refreshOutlineView {
    // Here we are going to refresh the items displayed based on the user's search
    
    NSString* searchString = [self.searchField.stringValue lowercaseString];
    
    if (self.searchField.stringValue.length > 0) {

        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            // First check to see if the parent row contains the string
            NSDictionary *dictionary = (NSDictionary *)evaluatedObject;
            for (NSString *key in dictionary) {
                id value = dictionary[key];
                if ([value isKindOfClass:[NSString class]] && [[value lowercaseString] containsString:searchString]) {
                    return YES;
                }
                // Check if the string exists within any permissions
                else if ([value isKindOfClass:[NSArray class]]) {
                    for (NSDictionary* permission in value) {
                        NSString* service = [[permission valueForKey:@"service"] lowercaseString];
                        if ([service containsString:searchString]) {
                            return YES;
                        }
                    }
                }
            }
            return NO;
        }];
        
        // filter based on our searching predicate
        _sortedPermissions = [_unfilteredPermissions filteredArrayUsingPredicate:predicate];
    }
    else {
        _sortedPermissions = _unfilteredPermissions;
    }
    
    [self.outlineView reloadData];
}

- (IBAction)openAppUsage:(id)sender {
    
    // This is a funky way of pulling the application name from the responsible cell
    NSButton* button = (NSButton*)sender;
    NSView* cell = button.superview;
    

    
    // Let's find the item that the button relates to
    NSInteger row = [self.outlineView rowForView:cell];
    NSDictionary* item = [self.outlineView itemAtRow:row];

    NSString* appName = [item valueForKey:@"app_client"];
    
    Bundle* target = [self getBundle:appName];
    self.applicationUsageController = [[ApplicationUsageController alloc] initWithWindowNibName:@"ApplicationUsage"];

    // Where possible let's pull the app name, lots of checks in case things don't exist
    if (target != nil) {
        if (target.name != nil) {
            self.applicationUsageController.application = target.name;
        }
        else {
            self.applicationUsageController.application = appName;
        }
    }
    else {
        self.applicationUsageController.application = appName;
    }
    
    self.applicationUsageController.applicationBundleName = appName;
    [self.applicationUsageController showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)createCondition:(NSDictionary*)permissionRow {
    
    Bundle* target = [self getBundle:[permissionRow valueForKey:@"client"]];
    self.tccPermissionWindowController = [[TCCPermissionWindowController alloc] initWithWindowNibName:@"TCCPermissionToggler"];

    // Where possible let's pull the app name and app icon
    if (target != nil) {
        if (target.name != nil) {
            self.tccPermissionWindowController.application = target.name;
        }
        self.tccPermissionWindowController.applicationIcon = target.icon;
    }
    else {
        self.tccPermissionWindowController.application = [permissionRow valueForKey:@"client"];
    }
    self.tccPermissionWindowController.bundleId = [permissionRow valueForKey:@"client"];
    self.tccPermissionWindowController.permission = [permissionRow valueForKey:@"service"];

    [self.tccPermissionWindowController showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
}

@end
