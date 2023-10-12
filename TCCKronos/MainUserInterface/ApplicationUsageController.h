
//  ApplicationUsageController.h
//  TCCKronos




@import Cocoa;

#import "DatabaseController.h"
#import "XPCConnection.h"
#import "Utils.h"

NS_ASSUME_NONNULL_BEGIN

@interface ApplicationUsageController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource>

@property (strong) NSString* application;
@property (strong) NSString* applicationBundleName;

@property (strong) NSString* permission;

@property (strong) IBOutlet NSTableView *tableView;

@end

NS_ASSUME_NONNULL_END
