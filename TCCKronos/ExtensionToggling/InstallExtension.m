
//  InstallExtension.m
//  TCCKronos




#import <Foundation/Foundation.h>
#import "InstallExtension.h"

@interface InstallExtension ()

@property (strong) OSSystemExtensionRequest *currentRequest;

@end


@implementation InstallExtension

-(void) install {
    NSLog(@"Beginning to install the extension");

    OSSystemExtensionRequest *req = [OSSystemExtensionRequest activationRequestForExtension:@"io.phorion.tcc-kronos.TCCKronosExtension" queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    req.delegate = self;
    
    [[OSSystemExtensionManager sharedManager] submitRequest:req];
    self.currentRequest = req;
}

- (OSSystemExtensionReplacementAction)request:(OSSystemExtensionRequest OS_UNUSED *)request actionForReplacingExtension:(OSSystemExtensionProperties *)existing withExtension:(OSSystemExtensionProperties *)extension
{
    NSLog(@"Got the upgrade request (%@ -> %@); answering replace.", existing.bundleVersion, extension.bundleVersion);
    return OSSystemExtensionReplacementActionReplace;
}

- (void)requestNeedsUserApproval:(OSSystemExtensionRequest *)request
{
    if (request != self.currentRequest) {
        NSLog(@"UNEXPECTED NON-CURRENT Request to activate %@ succeeded.", request.identifier);
        return;
    }
    NSLog(@"Request to activate %@ awaiting approval.", request.identifier);
}

- (void)request:(OSSystemExtensionRequest *)request didFinishWithResult:(OSSystemExtensionRequestResult)result
{
    if (request != self.currentRequest) {
        NSLog(@"UNEXPECTED NON-CURRENT Request to activate %@ succeeded.", request.identifier);
        return;
    }
    NSLog(@"Request to activate %@ succeeded (%zu).", request.identifier, (unsigned long)result);
    self.currentRequest = nil;
}

- (void)request:(OSSystemExtensionRequest *)request didFailWithError:(NSError *)error
{
    if (request != self.currentRequest) {
        NSLog(@"UNEXPECTED NON-CURRENT Request to activate %@ failed with error %@.", request.identifier, error);
        return;
    }
    NSLog(@"Request to activate %@ failed with error %@.", request.identifier, error);
    self.currentRequest = nil;
}


@end
