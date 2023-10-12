
//  XPCApp.h
//  TCCKronos




#import <Foundation/Foundation.h>
#import "XPCAppProtocol.h"
#import "TCCEventWindowController.h"

NS_ASSUME_NONNULL_BEGIN

@interface XPCApp : NSObject <XPCAppProtocol>

@property(nonatomic, retain)TCCEventWindowController* tccEventWindowController;

@end

NS_ASSUME_NONNULL_END
