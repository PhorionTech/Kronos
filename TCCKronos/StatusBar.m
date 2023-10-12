
//  StatusBar.m
//  tcc-kronos




#import <Foundation/Foundation.h>
#import "StatusBar.h"

@implementation StatusBar

@synthesize statusItem;

-(instancetype)init:(NSMenu*)statusMenu
{
    self = [super init];
    
    [self setMenuItems:statusMenu];
    return self;
};

-(BOOL)setMenuItems:(NSMenu*)statusMenu {
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    self.statusItem.menu = statusMenu;
    self.statusItem.button.image = [NSImage imageNamed:@"phorion-status-item"];
    
    return true;
}

@end
