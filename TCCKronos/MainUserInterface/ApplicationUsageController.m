
//  ApplicationUsageController.m
//  TCCKronos




#import "ApplicationUsageController.h"
#import "AppDelegate.h"

@implementation ApplicationUsageController {
    NSArray<NSDictionary*>* _appUsage;
}

- (void)windowDidLoad {
    
    // We are passing the application name when opening this window
    _appUsage = [[XPCConnection shared] dbUsageForApp:_applicationBundleName];//self.application];
    [[self window] setTitle:_application];
}

//on window close
// set activation policy
-(void)windowWillClose:(NSNotification *)notification
{
    [self callActivationPolicy];
    return;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_appUsage count];
}

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSDictionary *dataItem = [_appUsage objectAtIndex:row];
    
    NSTableCellView* cell;
    
    // Ensure the right formatting for the service cell
    if (tableColumn == self.tableView.tableColumns[1]) {
        cell = [tableView makeViewWithIdentifier:@"serviceCellData" owner:self];
    }
    else {
        cell = [tableView makeViewWithIdentifier:@"cellData" owner:self];
    }
    
    // timestamp
    if(tableColumn == self.tableView.tableColumns[0]) {
        cell.textField.stringValue = formatDateWithNumber([dataItem valueForKey:@"timestamp"]);
    }
    // service
    else if (tableColumn == self.tableView.tableColumns[1]) {
        cell.textField.stringValue = [dataItem valueForKey:@"service"];
    }
    // accessing identifier
    else if (tableColumn == self.tableView.tableColumns[2]) {
        cell.textField.stringValue = [dataItem valueForKey:@"accessingIdentifier"];
    }
    // accessing path
    else if (tableColumn == self.tableView.tableColumns[3]) {
        cell.textField.stringValue = [dataItem valueForKey:@"accessingPath"];
    }
    // result
    else if (tableColumn == self.tableView.tableColumns[4]) {
        cell.textField.stringValue = [dataItem valueForKey:@"didResult"];
    }

    return cell;
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

@end
