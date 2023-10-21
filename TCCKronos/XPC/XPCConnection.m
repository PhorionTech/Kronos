//
//  XPCConnection.m
//  TCCKronos
//
//  Created by Luke Roberts on 12/09/2023.
//

#import "XPCConnection.h"
#import "XPCAppProtocol.h"
#import "XPCExtProtocol.h"
#import "XPCApp.h"

#import "Constants.h"
#import "Utils.h"

@implementation XPCConnection

@synthesize connection;

+ (id)shared
{
    static XPCConnection* xpcConnection = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xpcConnection = [[self alloc] init];
    });

    return xpcConnection;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        [self registerWithExtension];
    }
    
    return self;
}

- (void)registerWithExtension
{
    if (connection != nil) {
        NSLog(@"Already registered with the extension");
        return;
    }
    
    if (findProcess(SYSEXT_PROCESS_NAME) == -1) {
        NSLog(@"SysExt is not running");
        return;
    }

    connection = [[NSXPCConnection alloc] initWithMachServiceName:SYSEXT_BUNDLE_ID options:0];
    
    connection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XPCAppProtocol)];
    connection.exportedObject = [[XPCApp alloc] init];

    connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XPCExtProtocol)];
    connection.invalidationHandler = ^{
        NSLog(@"Failed to create XPC connection");
        self->connection = nil;
    };

    [connection resume];
    
    [self doRegister];
}

- (BOOL)isConnected
{
    return connection != nil;
}

- (void)stopConnection
{
    NSLog(@"Stopping the connection");
    
    if (connection != nil) {
        [connection invalidate];
    }
}

# pragma mark - Remote Method Helpers

- (NSString*)checkSysExtVersion
{
    __block NSString* result = @"";
    
    [[connection synchronousRemoteObjectProxyWithErrorHandler:^(NSError* error)
    {
      NSLog(@"ERROR: failed to execute daemon XPC method '%s' (error: %@)", __PRETTY_FUNCTION__, error);
      
    }] checkSysExtVersionWithReply:^(NSString* reply) {
        result = reply;
    }];
    
    return result;
}

- (BOOL)checkFDA
{
    __block BOOL result = NO;
    
    [[connection synchronousRemoteObjectProxyWithErrorHandler:^(NSError* error)
    {
      NSLog(@"ERROR: failed to execute daemon XPC method '%s' (error: %@)", __PRETTY_FUNCTION__, error);
      
    }] checkFDAWithReply:^(BOOL reply) {
        result = reply;
    }];
    return result;
}

- (BOOL)retractTCCPermission:(NSString*)service withBundle:(NSString*)bundleId
{
    __block BOOL result = NO;

    [[connection synchronousRemoteObjectProxyWithErrorHandler:^(NSError* error)
    {
      NSLog(@"ERROR: failed to execute daemon XPC method '%s' (error: %@)", __PRETTY_FUNCTION__, error);
    }] retractTCCPermission:service withBundle:bundleId withReply:^(BOOL reply) {
        result = reply;
    }];
    return result;
}

- (NSArray<NSDictionary*>*)tccSelectAll {
    __block NSArray<NSDictionary*>* result;
    
    [[connection synchronousRemoteObjectProxyWithErrorHandler:^(NSError* error)
    {
      NSLog(@"ERROR: failed to execute daemon XPC method '%s' (error: %@)", __PRETTY_FUNCTION__, error);
      
    }] tccSelectAllWithReply:^(NSArray<NSDictionary *> * _Nonnull reply) {
        result = reply;
    }];
    
    return result;
}

- (NSDictionary*)tccSelectRecordByClient:(NSString*)client service:(NSString*)service {
    __block NSDictionary* result;
    
    [[connection synchronousRemoteObjectProxyWithErrorHandler:^(NSError* error)
    {
      NSLog(@"ERROR: failed to execute daemon XPC method '%s' (error: %@)", __PRETTY_FUNCTION__, error);
      
    }] tccSelectRecordByClient:client service:service withReply:^(NSDictionary * _Nonnull reply) {
        result = reply;
    }];
    
    return result;
}

- (NSDictionary*)dbConditionsForService:(NSString*)service forApp:(NSString*)appIdentifier {
    __block NSDictionary* result;
    
    [[connection synchronousRemoteObjectProxyWithErrorHandler:^(NSError* error)
    {
      NSLog(@"ERROR: failed to execute daemon XPC method '%s' (error: %@)", __PRETTY_FUNCTION__, error);
      
    }] dbConditionsForService:service forApp:appIdentifier withReply:^(NSDictionary * _Nonnull reply) {
        result = reply;
    }];
    
    return result;
}

- (BOOL)addCondition:(NSString*)condition withValue:(NSString*)value withIdentifier:(NSString*)identifier forService:(NSString*)service forApp:(NSString*)app {
    __block BOOL result = NO;

    [[connection synchronousRemoteObjectProxyWithErrorHandler:^(NSError* error)
    {
      NSLog(@"ERROR: failed to execute daemon XPC method '%s' (error: %@)", __PRETTY_FUNCTION__, error);
    }] addCondition:condition withValue:value withIdentifier:identifier forService:service forApp:app withReply:^(BOOL reply) {
        result = reply;
    }];
    
    return result;
}

- (NSArray<NSDictionary*>*)dbUsageForApp:(NSString*)appIdentifier {
    __block NSArray<NSDictionary*>* result;
    
    [[connection synchronousRemoteObjectProxyWithErrorHandler:^(NSError* error)
    {
      NSLog(@"ERROR: failed to execute daemon XPC method '%s' (error: %@)", __PRETTY_FUNCTION__, error);
      
    }] dbUsageForApp:appIdentifier withReply:^(NSArray<NSDictionary *> * _Nonnull reply) {
        result = reply;
    }];
    
    return result;
}

- (NSDictionary*)getUsageByMsgID:(NSString*)msgID {
    __block NSDictionary* result;
    
    [[connection synchronousRemoteObjectProxyWithErrorHandler:^(NSError* error)
    {
      NSLog(@"ERROR: failed to execute daemon XPC method '%s' (error: %@)", __PRETTY_FUNCTION__, error);
      
    }] getUsageByMsgID:msgID withReply:^(NSDictionary * _Nonnull reply) {
        result = reply;
    }];
    
    return result;
}

- (NSArray<NSDictionary*>*)getConditions {
    __block NSArray<NSDictionary*>* result;
    
    [[connection synchronousRemoteObjectProxyWithErrorHandler:^(NSError* error)
    {
      NSLog(@"ERROR: failed to execute daemon XPC method '%s' (error: %@)", __PRETTY_FUNCTION__, error);
      
    }] getConditionsWithReply:^(NSArray<NSDictionary *> * _Nonnull reply) {
        result = reply;
    }];
    
    return result;
}

- (void)doRegister {
    [[connection synchronousRemoteObjectProxyWithErrorHandler:^(NSError* error)
    {
      NSLog(@"ERROR: failed to execute daemon XPC method '%s' (error: %@)", __PRETTY_FUNCTION__, error);
      
    }] doRegister];
}


@end
