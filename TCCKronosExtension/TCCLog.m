
//  TCCLog.m
//  tcc-kronos




#import "TCCLog.h"

#import "Utils.h"

#import <OSLog/OSLog.h>

@implementation TCCLog

- (instancetype)init:(OSLogEntry*)log
{
    self = [super init];
    if (self) {
        _message = [log composedMessage];
        _data = [NSMutableDictionary dictionary];
        _timestamp = [log date];
        
        [self parseMessage:_message];
    }
    return self;
}

- (instancetype)initFromString:(NSString *)message
{
    self = [super init];
    if (self) {
        _message = message;
        _data = [NSMutableDictionary dictionary];
        _timestamp = [NSDate now];
        
        [self parseMessage:_message];
    }
    return self;
}

- (void)parseMessage:(NSString*)message
{
    _type = [message componentsSeparatedByString:@":"][0];
    _msgID = parseStringWithRegex(@"msgID=(\\d+\\.\\d+)", message);
    
    if ([_type isEqual: @"REQUEST"]) {
        _function = parseStringWithRegex(@"function=(TCC\\w+),", message);
        // REQUEST: tccd_uid=0, sender_pid=150, sender_uid=0, sender_auid=-1, function=TCCAccessRequest, msgID=150.33
        
    } else if ([_type isEqual: @"AUTHREQ_CTX"]) {
        // AUTHREQ_CTX: msgID=150.33, function=TCCAccessRequest, service=kTCCServiceSystemPolicyAllFiles, preflight=yes, query=1,
        _data[@"service"]   = parseStringWithRegex(@"service=(k\\w+),", message);
        _data[@"preflight"] = parseStringWithRegex(@"preflight=(yes|no),", message);
        _data[@"query"]     = parseStringWithRegex(@"query=(\\d)", message);
        
    } else if ([_type isEqual:@"AUTHREQ_ATTRIBUTION"]) {
        // AUTHREQ_ATTRIBUTION: msgID=150.33, attribution={responsible={<TCCDProcess: identifier=com.apple.Terminal, pid=436, auid=501, euid=501, responsible_path=/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal, binary_path=/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal>}, accessing={<TCCDProcess: identifier=com.apple.ls, pid=1253, auid=501, euid=501, binary_path=/bin/ls>}, requesting={<TCCDProcess: identifier=com.apple.sandboxd, pid=150, auid=0, euid=0, binary_path=/usr/libexec/sandboxd>}, },
        NSString* responsible = parseStringWithRegex(@"responsible=\\{(?:<?TCCDProcess: )?([^>}]+)>?\\},", message);
        _data[@"responsible"] = [self parseTCCDProcessString:responsible];
        
        NSString* accessing   = parseStringWithRegex(@"accessing=\\{(?:<?TCCDProcess: )?([^>}]+)>?\\},", message);
        _data[@"accessing"]   = [self parseTCCDProcessString:accessing];
        
        NSString* requesting  = parseStringWithRegex(@"requesting=\\{(?:<?TCCDProcess: )?([^>}]+)>?\\},", message);
        _data[@"requesting"]  = [self parseTCCDProcessString:requesting];
        
    } else if ([_type isEqual:@"AUTHREQ_SUBJECT"]) {
        // AUTHREQ_SUBJECT: msgID=150.33, subject=com.apple.Terminal,
        _data[@"subject"] = parseStringWithRegex(@"subject=([^,]+),", message);
        
    } else if ([_type isEqual:@"AUTHREQ_RESULT"]) {
        // AUTHREQ_RESULT: msgID=150.33, authValue=0, authReason=5, authVersion=1, error=(null),
        _data[@"authValue"] = parseStringWithRegex(@"authValue=(\\d+)", message);
        _data[@"authReason"] = parseStringWithRegex(@"authReason=(\\d+)", message);
        _data[@"authVersion"] = parseStringWithRegex(@"authVersion=(\\d)+", message);
        _data[@"error"] = parseStringWithRegex(@"error=(.+),", message);
        
    } else if ([_type isEqual:@"AUTHREQ_PROMPTING"]) {
        // AUTHREQ_PROMPTING: msgID=150.34, service=kTCCServiceSystemPolicyDownloadsFolder, subject=Sub:{com.apple.Terminal}Resp:{<TCCDProcess: identifier=com.apple.Terminal, pid=436, auid=501, euid=501, responsible_path=/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal, binary_path=/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal>},
        _data[@"service"] = parseStringWithRegex(@"service=(k\\w+),", message);
        
        NSString* responsible = parseStringWithRegex(@"Resp:\\{(?:<?TCCDProcess: )?([^>]+)>?\\}", message);
        _data[@"responsible"] = [self parseTCCDProcessString:responsible];
    }
}

- (NSDictionary*)parseTCCDProcessString:(NSString*)tccdProcessString
{
    // identifier=com.apple.Terminal, pid=436, auid=501, euid=501, responsible_path=/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal, binary_path=/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal
    NSMutableDictionary* output = [NSMutableDictionary dictionaryWithDictionary:@{
        @"identifier": parseStringWithRegex(@"identifier=([^,]+),", tccdProcessString),
        @"pid": parseStringWithRegex(@"pid=(\\d+)", tccdProcessString),
        @"auid": parseStringWithRegex(@"auid=(\\d+)", tccdProcessString),
        @"euid": parseStringWithRegex(@"euid=(\\d+)", tccdProcessString),
        @"binary_path": parseStringWithRegex(@"binary_path=(/.+)", tccdProcessString)
    }];
    
    NSString* responsible_path = parseStringWithRegex(@"responsible_path=(/.+),", tccdProcessString);
    
    if ([responsible_path isNotEqualTo:@""]) {
        output[@"responsible_path"] = responsible_path;
    }
    
    return output;
}

@end
