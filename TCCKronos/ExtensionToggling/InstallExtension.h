
//  InstallExtension.h
//  tcc-kronos




#import <SystemExtensions/SystemExtensions.h>

@interface InstallExtension : NSObject <OSSystemExtensionRequestDelegate>

-(void) install;

@end
