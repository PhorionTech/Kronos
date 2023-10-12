
//  Bundle.m
//  TCCKronos




#import "Bundle.h"

#import "Utils.h"
#import "Signing.h"

@implementation Bundle

+ (NSArray<Bundle*>*)bundlesFromIdentifier:(NSString*)identifier {
    NSMutableArray* output = [NSMutableArray array];

    NSArray* items = (__bridge_transfer NSArray*)LSCopyApplicationURLsForBundleIdentifier((__bridge_retained CFStringRef)identifier, nil);

    for (NSURL* item in items) {
        [output addObject:[Bundle bundleFromBundleURL:item]];
    }

    return output;
}

+ (Bundle*)bundleFromBinaryPath:(NSString*)binaryPath {
    NSBundle* bundle = findAppBundle(binaryPath);

    if (bundle == nil) {
        return nil;
    }
    
    return [[Bundle alloc] initWithBundle:bundle];
}


+ (Bundle*)bundleFromBundleURL:(NSURL*)bundleURL {
    NSBundle* bundle = [NSBundle bundleWithURL:bundleURL];

    return [[Bundle alloc] initWithBundle:bundle];
}

- (instancetype)initWithBundle:(NSBundle*)bundle {
    self = [super init];

    if (self) {
        _name = [[bundle infoDictionary] objectForKey:@"CFBundleName"];
        _version = [[bundle infoDictionary] objectForKey:@"CFBundleVersion"];
        _binaryPath = [bundle.executablePath stringByResolvingSymlinksInPath];
        _icon = getIconForBundle(bundle);
        _signingInfo = extractSigningInfo(0, [bundle bundlePath], kSecCSDefaultFlags | kSecCSCheckNestedCode | kSecCSDoNotValidateResources | kSecCSCheckAllArchitectures);
        _bundle = bundle;

    }

    return self;
}


@end
