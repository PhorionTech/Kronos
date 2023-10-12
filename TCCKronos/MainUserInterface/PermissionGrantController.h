
//  PermissionGrantController.h
//  TCCKronos




@import Cocoa;

#import "DatabaseController.h"
#import "XPCConnection.h"
#import "Utils.h"

NS_ASSUME_NONNULL_BEGIN

@interface PermissionGrantController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>
@property (strong) IBOutlet NSView *noGrantsView;

@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSImageView *appIcon;

@property (strong) NSArray<NSDictionary*>* currentGrants;


@end

NS_ASSUME_NONNULL_END
