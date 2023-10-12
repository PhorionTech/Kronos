
//  TCCUtilHelper.h
//  tcc-kronos




#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TCCUtilHelper : NSObject

+(BOOL)runTCCUtil:(NSString*)service withBundle:(NSString*)bundleId;

@end

NS_ASSUME_NONNULL_END
