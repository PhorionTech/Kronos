
//  UnifiedLogClient.m
//  TCCKronosExtension

// In version 1.2.6 we swapped the method of reading the unified log over to the private stream method used by Patrick Wardle's OverSight. Take a look here -> https://github.com/objective-see/OverSight
// Thanks Patrick! :)


#import "UnifiedLogClient.h"

#import "TCCLog.h"

#import <OSLog/OSLog.h>

@implementation OSLogEvent
+ (instancetype) OSLogEvent {
    return [[self alloc] init];
}
@end

@implementation UnifiedLogClient {
    OSLogStore* _osLog;
    NSPredicate* _tccSubsystemPredicate;
}

- (instancetype)init {
    NSError* error = nil;
    
    self = [super init];
    
    if (self) {
        _tccSubsystemPredicate = [NSPredicate predicateWithFormat:@"subsystem contains \"com.apple.TCC\""];
        
        //ensure `LoggingSupport.framework` is loaded
         if(YES != [[NSBundle bundleWithPath:LOGGING_SUPPORT] loadAndReturnError:&error])
         {
             //err msg
             NSLog(@"ERROR: failed to load logging framework %@ (error: %@)", LOGGING_SUPPORT, error);

             //unset
             self = nil;
         }
    }
    return self;
}

// https://github.com/objective-see/OverSight/blob/cf9c983ff8eb68a6aeb3d9f15025f463f566aa18/Application/Application/LogMonitor.m#L75
- (BOOL)startEventStream:(void (^)(TCCLog* log))callback; {
    //flag
     BOOL started = NO;

     //live stream class
     Class LiveStream = nil;

     //event handler callback
     void (^eventHandler)(OSLogEventProxy* event) = ^void(OSLogEventProxy* event) {

         //Return the raw event
         NSLog(@"%@", event);
//         callback([[TCCLog alloc] init:logEntry]);
     };

     //get 'OSLogEventLiveStream' class
     if(nil == (LiveStream = NSClassFromString(@"OSLogEventLiveStream")))
     {
         //bail
         goto bail;
     }

     //init live stream
     self.liveStream = [[LiveStream alloc] init];
     if(nil == self.liveStream)
     {
         //bail
         goto bail;
     }

     //sanity check
     // obj responds to `setFilterPredicate:`?
     if(YES != [self.liveStream respondsToSelector:NSSelectorFromString(@"setFilterPredicate:")])
     {
         //bail
         goto bail;
     }

     //set predicate
     [self.liveStream setFilterPredicate:_tccSubsystemPredicate];

     //sanity check
     // obj responds to `setInvalidationHandler:`?
     if(YES != [self.liveStream respondsToSelector:NSSelectorFromString(@"setInvalidationHandler:")])
     {
         //bail
         goto bail;
     }

     //set invalidation handler
     // note: need to have somethigng set as this get called (indirectly) when
     //       the 'invalidate' method is called ... but don't need to do anything
     [self.liveStream setInvalidationHandler:^void (int reason, id streamPosition) {
         //NSLog(@"invalidation handler called with %d!", reason);
         ;
     }];

     //sanity check
     // obj responds to `setDroppedEventHandler:`?
     if(YES != [self.liveStream respondsToSelector:NSSelectorFromString(@"setDroppedEventHandler:")])
     {
         //bail
         goto bail;
     }

     //set dropped msg handler
     // note: need to have somethigng set as this get called (indirectly)
     [self.liveStream setDroppedEventHandler:^void (id droppedMessage)
     {
         //NSLog(@"invalidation handler called with %d!", reason);
         ;
     }];

     //sanity check
     // obj responds to `setEventHandler:`?
     if(YES != [self.liveStream respondsToSelector:NSSelectorFromString(@"setEventHandler:")])
     {
         //bail
         goto bail;
     }

     //set event handler
     [self.liveStream setEventHandler:eventHandler];

     //sanity check
     // obj responds to `activate:`?
     if(YES != [self.liveStream respondsToSelector:NSSelectorFromString(@"activate")])
     {
         //bail
         goto bail;
     }
     
     //
     if(YES != [self.liveStream respondsToSelector:NSSelectorFromString(@"setFlags:")])
     {
         //bail
         goto bail;
     }

     //set debug & info flags
     [self.liveStream setFlags:Log_Level_Default];
     
     //activate
     [self.liveStream activate];

     //happy
     started = YES;

 bail:
     return started;
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
