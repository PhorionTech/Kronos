//
//  Hasher.m
//  TCCKronos
//
//  Created by Luke Roberts on 20/11/2023.
//

#import "Hasher.h"

#import <CommonCrypto/CommonDigest.h>

@implementation Hasher


+ (NSString *)calculateSHA256ForFileAtPath:(NSString *)path
{
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
    if (file == nil) return nil;

    CC_SHA256_CTX hashObject;
    CC_SHA256_Init(&hashObject);

    BOOL done = NO;
    while (!done)
    {
        NSData *fileData = [file readDataOfLength:4096];
        CC_SHA256_Update(&hashObject, [fileData bytes], (CC_LONG)[fileData length]);
        if ([fileData length] == 0) done = YES;
    }

    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256_Final(digest, &hashObject);
    [file closeFile];

    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
    {
        [hash appendFormat:@"%02x", digest[i]];
    }

    return [hash copy];
}

@end
