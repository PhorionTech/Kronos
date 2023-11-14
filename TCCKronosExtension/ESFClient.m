
//  ESFClient.m
//  TCCKronosExtension




#import "ESFClient.h"
#import <bsm/libbsm.h>
#import <Kernel/kern/cs_blobs.h>

#include "XPCListener.h"
#include "Utils.h"
#include "Constants.h"

#include <EndpointSecurity/EndpointSecurity.h>


@implementation ESFClient {
    XPCListener* _xpc;
    es_client_t* _client;
}

es_event_type_t events[] = {
    ES_EVENT_TYPE_NOTIFY_WRITE
};


- (instancetype)initWithXPC:(XPCListener*)xpc
{
    self = [super init];
    if (self) {
        _xpc = xpc;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_ESF]) {
            [self start];
        }
    }
    return self;
}

- (BOOL)start {
    @synchronized(self) {
        es_new_client_result_t result = es_new_client(&_client, ^(es_client_t *c, const es_message_t *msg) {
            [self handleEvent:msg];
        });
        
        if (result != ES_NEW_CLIENT_RESULT_SUCCESS) {
            NSLog(@"Failed to create new ES client: %d", result);
            return NO;
        }
        
        if (es_subscribe(_client, events, sizeof(events) / sizeof(events[0])) != ES_RETURN_SUCCESS) {
            NSLog(@"Failed to subscribe to events");
            es_delete_client(_client);
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)stop {
    @synchronized(self) {
        if (_client != NULL) {
            if (es_unsubscribe_all(_client) != ES_RETURN_SUCCESS) {
                return NO;
            }
            
            if (es_delete_client(_client) != ES_RETURN_SUCCESS) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)handleEvent:(const es_message_t*)message {
    switch (message->event_type) {
        case ES_EVENT_TYPE_NOTIFY_WRITE:
            [self handleNotifyWriteEvent:message];
            break;
            
        default:
            NSLog(@"Unexpected event type encountered: %d\n", message->event_type);
            break;
    }
}

- (void)handleNotifyWriteEvent:(const es_message_t*)message {
    if (message->process->is_es_client) {
        return;
    }
        
    NSString* path = [self convertStringToken:&message->event.write.target->path];
    
    if ([path hasSuffix:@"/Library/Application Support/com.apple.TCC/TCC.db"]) {
        NSString* signingID = [self convertStringToken:&message->process->signing_id];
        
        if ([signingID isEqual:@"com.apple.tccd"]) {
            return;
        }
        
        NSDictionary* info = @{
            @"path": path
        };
        
        [_xpc sendTamperingNotification:[self buildGenericEventInfoDictionary:message WithDictionary:info]];
    }
}

- (NSDictionary*)buildGenericEventInfoDictionary:(const es_message_t*)message WithDictionary:(NSDictionary*)source {
    NSTimeInterval timeInNs = (message->time.tv_sec + (message->time.tv_nsec / 1000000000.0));
    NSString* binarypath = [self convertStringToken:&message->process->executable->path];
    NSNumber* uid = [NSNumber numberWithInt:audit_token_to_euid(message->process->audit_token)];
    NSString* username = convertEuidToUsername(uid);
    NSNumber* pid = [NSNumber numberWithInt:audit_token_to_pid(message->process->audit_token)];
    NSNumber* ppid = [NSNumber numberWithInt:message->process->ppid];


    NSArray* flags = [self parseCodeSignFlags:message->process->codesigning_flags];
    NSString* signingID = [self convertStringToken:&message->process->signing_id];
    NSString* teamID = [self convertStringToken:&message->process->team_id];
    NSNumber* isPlatformBinary = [NSNumber numberWithBool:message->process->is_platform_binary];

    NSMutableString* cdHash = [NSMutableString string];
    for (uint32_t i = 0; i < CS_CDHASH_LEN; i++) {
        [cdHash appendFormat:@"%X", message->process->cdhash[i]];
    }
    
    if (binarypath == nil) {
        binarypath = @"";
    }
    
    NSMutableDictionary* output = [NSMutableDictionary dictionaryWithDictionary:@{
        @"timestamp": [NSDate dateWithTimeIntervalSince1970:timeInNs],
        @"binary_path": binarypath,
        @"uid": uid,
        @"username": username,
        @"pid": pid,
        @"ppid": ppid,
        @"flags": flags,
        @"signing_id": signingID,
        @"team_id": teamID,
        @"is_platform_binary": isPlatformBinary,
        @"cdhash": cdHash
    }];
    
    [output addEntriesFromDictionary:source];
    
    return output;
}

- (NSString*)convertStringToken:(es_string_token_t*)stringToken
{
    NSString* string = nil;

    if (NULL == stringToken || NULL == stringToken->data || stringToken->length <= 0) {
        return @"";
    }

    string = [NSString stringWithUTF8String:[[NSData dataWithBytes:stringToken->data length:stringToken->length] bytes]];

    return string;
}


- (NSArray*)parseCodeSignFlags:(uint32_t)value
{
    NSMutableArray* output = [NSMutableArray array];

    if ((CS_ADHOC & value) == CS_ADHOC) {
        [output addObject:@"CS_ADHOC"];
    }

    if ((CS_HARD & value) == CS_HARD) {
        [output addObject:@"CS_HARD"];
    }

    if ((CS_KILL & value) == CS_KILL) {
        [output addObject:@"CS_KILL"];
    }

    if ((CS_VALID & value) == CS_VALID) {
        [output addObject:@"CS_VALID"];
    }

    if ((CS_KILLED & value) == CS_KILLED) {
        [output addObject:@"CS_KILLED"];
    }

    if ((CS_SIGNED & value) == CS_SIGNED) {
        [output addObject:@"CS_SIGNED"];
    }

    if ((CS_RUNTIME & value) == CS_RUNTIME) {
        [output addObject:@"CS_RUNTIME"];
    }

    if ((CS_DEBUGGED & value) == CS_DEBUGGED) {
        [output addObject:@"CS_DEBUGGED"];
    }

    if ((CS_DEV_CODE & value) == CS_DEV_CODE) {
        [output addObject:@"CS_DEV_CODE"];
    }

    if ((CS_RESTRICT & value) == CS_RESTRICT) {
        [output addObject:@"CS_RESTRICT"];
    }

    if ((CS_FORCED_LV & value) == CS_FORCED_LV) {
        [output addObject:@"CS_FORCED_LV"];
    }

    if ((CS_INSTALLER & value) == CS_INSTALLER) {
        [output addObject:@"CS_INSTALLER"];
    }

    if ((CS_EXECSEG_JIT & value) == CS_EXECSEG_JIT) {
        [output addObject:@"CS_EXECSEG_JIT"];
    }

    if ((CS_REQUIRE_LV & value) == CS_REQUIRE_LV) {
        [output addObject:@"CS_EXECSEG_JIT"];
    }

    if ((CS_ALLOWED_MACHO & value) == CS_ALLOWED_MACHO) {
        [output addObject:@"CS_ALLOWED_MACHO"];
    }

    if ((CS_ENFORCEMENT & value) == CS_ENFORCEMENT) {
        [output addObject:@"CS_ENFORCEMENT"];
    }

    if ((CS_DYLD_PLATFORM & value) == CS_DYLD_PLATFORM) {
        [output addObject:@"CS_DYLD_PLATFORM"];
    }

    if ((CS_EXEC_SET_HARD & value) == CS_EXEC_SET_HARD) {
        [output addObject:@"CS_EXEC_SET_HARD"];
    }

    if ((CS_PLATFORM_PATH & value) == CS_PLATFORM_PATH) {
        [output addObject:@"CS_PLATFORM_PATH"];
    }

    if ((CS_GET_TASK_ALLOW & value) == CS_GET_TASK_ALLOW) {
        [output addObject:@"CS_GET_TASK_ALLOW"];
    }

    if ((CS_EXEC_SET_KILL & value) == CS_EXEC_SET_KILL) {
        [output addObject:@"CS_EXEC_SET_KILL"];
    }

    if ((CS_EXECSEG_SKIP_LV & value) == CS_EXECSEG_SKIP_LV) {
        [output addObject:@"CS_EXECSEG_SKIP_LV"];
    }

    if ((CS_INVALID_ALLOWED & value) == CS_INVALID_ALLOWED) {
        [output addObject:@"CS_INVALID_ALLOWED"];
    }

    if ((CS_CHECK_EXPIRATION & value) == CS_CHECK_EXPIRATION) {
        [output addObject:@"CS_INVALID_ALLOWED"];
    }

    if ((CS_PLATFORM_BINARY & value) == CS_PLATFORM_BINARY) {
        [output addObject:@"CS_PLATFORM_BINARY"];
    }

    if ((CS_EXEC_INHERIT_SIP & value) == CS_EXEC_INHERIT_SIP) {
        [output addObject:@"CS_EXEC_INHERIT_SIP"];
    }

    if ((CS_EXECSEG_ALLOW_UNSIGNED & value) == CS_EXECSEG_ALLOW_UNSIGNED) {
        [output addObject:@"CS_EXECSEG_ALLOW_UNSIGNED"];
    }

    if ((CS_EXECSEG_DEBUGGER & value) == CS_EXECSEG_DEBUGGER) {
        [output addObject:@"CS_EXECSEG_DEBUGGER"];
    }

    if ((CS_ENTITLEMENT_FLAGS & value) == CS_ENTITLEMENT_FLAGS) {
        [output addObject:@"CS_ENTITLEMENT_FLAGS"];
    }

    if ((CS_NVRAM_UNRESTRICTED & value) == CS_NVRAM_UNRESTRICTED) {
        [output addObject:@"CS_NVRAM_UNRESTRICTED"];
    }

    if ((CS_EXECSEG_MAIN_BINARY & value) == CS_EXECSEG_MAIN_BINARY) {
        [output addObject:@"CS_EXECSEG_MAIN_BINARY"];
    }
    
    return output;
}



@end
