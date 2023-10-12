
//  StatusBar.h
//  tcc-kronos




#import <Cocoa/Cocoa.h>

@interface StatusBar : NSObject

@property(nonatomic, strong, readwrite)NSStatusItem *statusItem;

-(instancetype)init:(NSMenu*)statusMenu;
-(BOOL)setMenuItems:(NSMenu*)statusMenu;

@end
