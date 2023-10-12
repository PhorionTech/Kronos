
//  XPCListener.m
//  TCCKronosExtension




#import "XPCListener.h"

#import "XPCAppProtocol.h"
#import "XPCExtProtocol.h"
#import "XPCExt.h"

#import "ConnectionVerifier.h"
#import "TCCHelper.h"
#import "TCCLog.h"
#import "DatabaseController.h"
#import "Constants.h"

@implementation XPCListener {
    DatabaseController* _db;
    RevocationService* _revocationService;
}

@synthesize connection;
@synthesize listener;

- (id)initWithDatabase:(DatabaseController*)db revocationService:(RevocationService*)revocationService;
{
    self = [super init];

    if (self != nil) {
        _db = db;
        _revocationService = revocationService;
        
        NSXPCListener* xpcListener = [NSXPCListener alloc];

        NSLog(@"Initating XPC listener for mach service %@", SYSEXT_BUNDLE_ID);
        listener = [xpcListener initWithMachServiceName:SYSEXT_BUNDLE_ID];

        self.listener.delegate = self;
        [self.listener resume];
    }

    return self;
}

- (BOOL)listener:(NSXPCListener*)listener shouldAcceptNewConnection:(NSXPCConnection*)newConnection
{
    if ([ConnectionVerifier isValid:newConnection] == NO) {
        return NO;
    }
    
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XPCExtProtocol)];
    newConnection.exportedObject = [[XPCExt alloc] initWithUid:newConnection.effectiveUserIdentifier database:_db revocationService:_revocationService];

    newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XPCAppProtocol)];

    newConnection.invalidationHandler = ^{
        NSLog(@"Invalidation handler called.");
        self->connection = nil;
    };
    
    newConnection.interruptionHandler = ^{
        NSLog(@"Interruption handler called.");
        self->connection = nil;
    };

    self.connection = newConnection;
    [newConnection resume];

    return YES;
}

# pragma mark - Remote Method Helpers

- (void)sendPromptingNotification:(NSDictionary*)log {
    if (self.connection == nil) {
        return;
    }
    
    [[self.connection remoteObjectProxy] promptingNotification:log];
}

- (void)sendTamperingNotification:(NSDictionary*)info {
    if (self.connection == nil) {
        return;
    }
    
    [[self.connection remoteObjectProxy] tamperingNotification:info];
}

- (void)sendRevokeNotification:(NSDictionary*)info {
    if (self.connection == nil) {
        return;
    }
    
    [[self.connection remoteObjectProxy] revokeNotification:info];
}


@end
