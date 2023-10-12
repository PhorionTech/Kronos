
//  TCCUtilHelper.m
//  tcc-kronos




#import <Foundation/Foundation.h>
#import "TCCUtilHelper.h"

@implementation TCCUtilHelper


+(BOOL)runTCCUtil:(NSString*)service withBundle:(NSString*)bundleId {
    
    // We are having to use the tccutil command line utility
    // as we can't use Apple's com.apple.private.tcc.manager.access.delete entitlement
    // which would allow us to use the TCC framework
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    
    service = [service stringByReplacingOccurrencesOfString:@"kTCCService" withString:@""];

    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/tccutil";
    task.arguments = @[@"reset", service, bundleId];
    task.standardOutput = pipe;

    [task launch];

    NSData *data = [file readDataToEndOfFile];
    [file closeFile];

    NSString *tccutilResult = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog(@"tccutil returned:\n%@", tccutilResult);
        
    // Check to see if a successfully reset message has been returned
    if ([tccutilResult hasPrefix:@"Successfully reset"]) {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

@end
