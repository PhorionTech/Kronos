
//  DispatchTimer.m
//  Kronos




#import "DispatchTimer.h"

@implementation DispatchTimer {
    dispatch_source_t timer;
    NSTimeInterval _interval;
    double _tolerance;
}

- (instancetype)initWithInterval:(NSTimeInterval)interval tolorance:(double)tolerance queue:(dispatch_queue_t)queue block:(dispatch_block_t)block
{
    self = [super init];

    if (self) {
        _interval = interval;
        _tolerance = tolerance;

        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_event_handler(timer, block);
    }

    return self;
}

- (void)dealloc
{
    dispatch_source_cancel(timer);
}

- (void)start
{
    assert(timer);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, _interval), _interval, _tolerance);
    dispatch_resume(timer);
}

- (void)cancel
{
    dispatch_source_cancel(timer);
}

- (BOOL)isValid
{
    return timer && 0 == dispatch_source_testcancel(timer);
}

@end
