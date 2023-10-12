
//  DispatchTimer.h
//  Kronos




#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DispatchTimer : NSObject

- (instancetype)initWithInterval:(NSTimeInterval)interval tolorance:(double)tolerance queue:(dispatch_queue_t)queue block:(dispatch_block_t)block;

- (void)dealloc;

- (void)start;

- (void)cancel;

- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
