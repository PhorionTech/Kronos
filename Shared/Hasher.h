//
//  Hasher.h
//  TCCKronos
//
//  Created by Luke Roberts on 20/11/2023.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Hasher : NSObject

+ (NSString *)calculateSHA256ForFileAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
