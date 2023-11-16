
//  PermissionGrantController.m
//  TCCKronos


#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#import "PermissionGrantController.h"
#import "AppDelegate.h"

#import "Bundle.h"
#import "Utils.h"

@implementation PermissionGrantController

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_currentGrants count];
}

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSImage* defaultIcon = [[NSWorkspace sharedWorkspace] iconForContentType:UTTypeApplicationBundle];

    [defaultIcon setSize:NSMakeSize(128, 128)];
    
    NSDictionary *dataItem = [_currentGrants objectAtIndex:row];
    NSString* appIdentifier = [dataItem valueForKey:@"appIdentifier"];
    NSTableCellView* cell;
    

    // Ensure the right formatting for the app name cell
    if (tableColumn == self.tableView.tableColumns[0]) {
        cell = [tableView makeViewWithIdentifier:@"appCell" owner:self];
        
    }
    else {
        cell = [tableView makeViewWithIdentifier:@"permissionCell" owner:self];
    }
    
    if(tableColumn == self.tableView.tableColumns[0]) {
        
        // We want to set the icon to ideally the bundle image, otherwise the default
        NSImageView* appIcon = [cell viewWithTag:141];
        [appIcon setImage:defaultIcon];

        Bundle* target = [self getBundle:appIdentifier];
        
        if (target != nil) {
            if (target.name != nil) {
                cell.textField.stringValue = target.name;
            }
            if (target.icon != nil) {
                [appIcon setImage:target.icon];
            }
        }
        else {
            cell.textField.stringValue = [dataItem valueForKey:@"appIdentifier"];
        }
    }
    // service
    else if (tableColumn == self.tableView.tableColumns[1]) {
        cell.textField.stringValue = [dataItem valueForKey:@"service"];
    }
    // condition
    else if (tableColumn == self.tableView.tableColumns[2]) {
        cell.textField.stringValue = [dataItem valueForKey:@"conditionType"];
    }
    // condition value, i.e. timestamp
    else if (tableColumn == self.tableView.tableColumns[3]) {
        cell.textField.stringValue = [dataItem valueForKey:@"conditionValue"];
    }

    return cell;
}

-(Bundle*)getBundle:(NSString*)appIdentifier {
    Bundle* target = nil;

    if ([appIdentifier hasPrefix:@"/"]) {
        // Treat as a path, can pull the type from the db to do this better...
        target = [Bundle bundleFromBinaryPath:appIdentifier];
    } else {
        NSArray<Bundle*>* bundlesForIdentifier = [Bundle bundlesFromIdentifier:appIdentifier];
    
        for (Bundle* bundle in bundlesForIdentifier) {
            if (bundle.icon != nil) {
                target = bundle;
                break;
            }
        }
    }
    return target;
}


@end
