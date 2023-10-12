
//  Bundle.h
//  TCCKronos




#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Bundle : NSObject

@property NSString* name;
@property NSString* version;
@property NSString* binaryPath;
@property NSImage* icon;
@property NSDictionary* signingInfo;
@property NSBundle* bundle;

+ (NSArray<Bundle*>*)bundlesFromIdentifier:(NSString*)identifier;
+ (Bundle*)bundleFromBinaryPath:(NSString*)binaryPath;
+ (Bundle*)bundleFromBundleURL:(NSURL*)bundleURL;

@end

NS_ASSUME_NONNULL_END
