
//  UnifiedLogClient.m
//  TCCKronosExtension




#import "UnifiedLogClient.h"

#import "TCCLog.h"

#import <OSLog/OSLog.h>

@implementation UnifiedLogClient {
    OSLogStore* _osLog;
    NSPredicate* _tccSubsystemPredicate;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _tccSubsystemPredicate = [NSPredicate predicateWithFormat:@"subsystem contains \"com.apple.TCC\""];
    }
    return self;
}


- (int)retrieveLatestEvents:(void (^)(TCCLog* log))callback; {
    OSLogPosition* logPosition;
    NSError* error;
    
    NSDate* now = [NSDate now];
    
    _osLog = [OSLogStore localStoreAndReturnError:nil];
    
    if (_lastPoll == nil) {
        logPosition = [_osLog positionWithDate:[NSDate dateWithTimeInterval:-1 sinceDate:now]];
    } else {
        logPosition = [_osLog positionWithDate:_lastPoll];
    }
    
    _lastPoll = now;
    

    OSLogEnumerator* enumerator = [_osLog entriesEnumeratorWithOptions:0 position:logPosition predicate:_tccSubsystemPredicate error:&error];
    
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return -1;
    }
    
    OSLogEntry* logEntry;
    int count = 0;
    
    while ((logEntry = [enumerator nextObject])) {
        callback([[TCCLog alloc] init:logEntry]);
        count++;
    }
    
    return count;
}

@end
