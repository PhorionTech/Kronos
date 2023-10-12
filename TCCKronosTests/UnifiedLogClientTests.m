
//  TCCKronosTests.m
//  TCCKronosTests




#import <XCTest/XCTest.h>

#import "UnifiedLogClient.h"
#import "TCCLog.h"

@interface UnifiedLogClientTests : XCTestCase

@end

@implementation UnifiedLogClientTests {
    UnifiedLogClient* _unifiedLogClient;
}

- (void)setUp {
    _unifiedLogClient = [[UnifiedLogClient alloc] init];
    _unifiedLogClient.lastPoll = [NSDate dateWithTimeIntervalSinceNow:-60];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testUnifiedLogInit {
    XCTAssertNotNil(_unifiedLogClient);
}

- (void)testUnifiedLogRead {
    int count = [_unifiedLogClient retrieveLatestEvents:^(TCCLog* log) {
        // Do nothing
    }];
    
    XCTAssertNotEqual(count, -1);
}



- (TCCLog*)helperUnifiedLogRead:(NSString*)type {
    return [self helperUnifiedLogRead:type withCommand:@"ls ~/Downloads" sleepFor:10];
}

- (TCCLog*)helperUnifiedLogRead:(NSString*)type withCommand:(NSString*)command sleepFor:(int)sleep {
    [self helperRunShellCommand:command];
    
    [NSThread sleepForTimeInterval:sleep];
    
    TCCLog* __block needle;
    
    [_unifiedLogClient retrieveLatestEvents:^(TCCLog* log) {
        if ([log.type isEqual:type]) {
            needle = log;
        }
    }];
    
    if (needle) {
        NSLog(@"Found %@: %@", needle.type, needle.message);
    }
        
    return needle;
}

- (void)helperRunShellCommand:(NSString*)command {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];

    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          command,
                          nil];
    
    [task setArguments:arguments];
    [task launch];

    NSLog(@"Ran /bin/sh %@", arguments);
}

- (void)testUnifiedLogReadRequest {
    TCCLog* needle = [self helperUnifiedLogRead:@"REQUEST"];
    
    XCTAssertNotNil(needle);
    XCTAssertEqualObjects(needle.type, @"REQUEST");
    XCTAssertNotEqualObjects(needle.msgID, @"");
}

- (void)testTCCLogParseRequest {
    NSString* message = @"REQUEST: tccd_uid=0, sender_pid=150, sender_uid=0, sender_auid=-1, function=TCCAccessRequest, msgID=150.33";
    
    TCCLog* log = [[TCCLog alloc] initFromString:message];
    XCTAssertNotNil(log);
    XCTAssertEqualObjects(log.msgID, @"150.33");
    XCTAssertEqualObjects(log.type, @"REQUEST");
    
    XCTAssertNotNil(log.data);
}

- (void)testUnifiedLogReadAuthReqCtx {
    TCCLog* needle = [self helperUnifiedLogRead:@"AUTHREQ_CTX"];
    
    XCTAssertNotNil(needle);
    XCTAssertEqualObjects(needle.type, @"AUTHREQ_CTX");
    XCTAssertNotEqualObjects(needle.msgID, @"");
    
    XCTAssertNotNil(needle.data);
    XCTAssertNotEqualObjects(needle.data[@"service"], @"");
    XCTAssertNotEqualObjects(needle.data[@"preflight"], @"");
    XCTAssertNotEqualObjects(needle.data[@"query"], @"");
}

- (void)testTCCLogParseAuthReqCtx {
    NSString* message = @"AUTHREQ_CTX: msgID=150.33, function=TCCAccessRequest, service=kTCCServiceSystemPolicyAllFiles, preflight=yes, query=1,";

    TCCLog* log = [[TCCLog alloc] initFromString:message];

    XCTAssertNotNil(log);
    XCTAssertEqualObjects(log.msgID, @"150.33");
    XCTAssertEqualObjects(log.type, @"AUTHREQ_CTX");
    
    XCTAssertNotNil(log.data);
    XCTAssertEqualObjects(log.data[@"service"], @"kTCCServiceSystemPolicyAllFiles");
    XCTAssertEqualObjects(log.data[@"preflight"], @"yes");
    XCTAssertEqualObjects(log.data[@"query"], @"1");
}

- (void)testUnifiedLogReadAuthReqAttribution {
    TCCLog* needle = [self helperUnifiedLogRead:@"AUTHREQ_ATTRIBUTION"];
    
    XCTAssertNotNil(needle);
    XCTAssertEqualObjects(needle.type, @"AUTHREQ_ATTRIBUTION");
    XCTAssertNotEqualObjects(needle.msgID, @"");
    
    XCTAssertNotNil(needle.data);
    
    if (needle.data[@"responsible"] != nil) {
        XCTAssertNotEqualObjects(needle.data[@"responsible"][@"identifier"], @"");
        XCTAssertNotEqualObjects(needle.data[@"responsible"][@"pid"], @"");
        XCTAssertNotEqualObjects(needle.data[@"responsible"][@"auid"], @"");
        XCTAssertNotEqualObjects(needle.data[@"responsible"][@"euid"], @"");
        XCTAssertNotEqualObjects(needle.data[@"responsible"][@"responsible_path"], @"");
        XCTAssertNotEqualObjects(needle.data[@"responsible"][@"binary_path"], @"");
    }
    
    XCTAssertNotNil(needle.data[@"accessing"]);
    XCTAssertNotEqualObjects(needle.data[@"accessing"][@"identifier"], @"");
    XCTAssertNotEqualObjects(needle.data[@"accessing"][@"pid"], @"");
    XCTAssertNotEqualObjects(needle.data[@"accessing"][@"auid"], @"");
    XCTAssertNotEqualObjects(needle.data[@"accessing"][@"euid"], @"");
    XCTAssertNotEqualObjects(needle.data[@"accessing"][@"binary_path"], @"");
    
    XCTAssertNotNil(needle.data[@"requesting"]);
    XCTAssertNotEqualObjects(needle.data[@"requesting"][@"identifier"], @"");
    XCTAssertNotEqualObjects(needle.data[@"requesting"][@"pid"], @"");
    XCTAssertNotEqualObjects(needle.data[@"requesting"][@"auid"], @"");
    XCTAssertNotEqualObjects(needle.data[@"requesting"][@"euid"], @"");
    XCTAssertNotEqualObjects(needle.data[@"requesting"][@"binary_path"], @"");
}

- (void)testTCCLogParseAuthReqAttribution {
    NSString* message = @"AUTHREQ_ATTRIBUTION: msgID=150.33, attribution={responsible={<TCCDProcess: identifier=com.apple.Terminal, pid=436, auid=501, euid=501, responsible_path=/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal, binary_path=/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal>}, accessing={<TCCDProcess: identifier=com.apple.ls, pid=1253, auid=501, euid=501, binary_path=/bin/ls>}, requesting={<TCCDProcess: identifier=com.apple.sandboxd, pid=150, auid=0, euid=0, binary_path=/usr/libexec/sandboxd>}, },";

    TCCLog* log = [[TCCLog alloc] initFromString:message];

    XCTAssertNotNil(log);
    XCTAssertEqualObjects(log.msgID, @"150.33");
    XCTAssertEqualObjects(log.type, @"AUTHREQ_ATTRIBUTION");
    
    XCTAssertNotNil(log.data);
    
    XCTAssertNotNil(log.data[@"responsible"]);
    XCTAssertEqualObjects(log.data[@"responsible"][@"identifier"], @"com.apple.Terminal");
    XCTAssertEqualObjects(log.data[@"responsible"][@"pid"], @"436");
    XCTAssertEqualObjects(log.data[@"responsible"][@"auid"], @"501");
    XCTAssertEqualObjects(log.data[@"responsible"][@"euid"], @"501");
    XCTAssertEqualObjects(log.data[@"responsible"][@"responsible_path"], @"/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal");
    XCTAssertEqualObjects(log.data[@"responsible"][@"binary_path"], @"/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal");
    
    XCTAssertNotNil(log.data[@"accessing"]);
    XCTAssertEqualObjects(log.data[@"accessing"][@"identifier"], @"com.apple.ls");
    XCTAssertEqualObjects(log.data[@"accessing"][@"pid"], @"1253");
    XCTAssertEqualObjects(log.data[@"accessing"][@"auid"], @"501");
    XCTAssertEqualObjects(log.data[@"accessing"][@"euid"], @"501");
    XCTAssertEqualObjects(log.data[@"accessing"][@"binary_path"], @"/bin/ls");
    
    XCTAssertNotNil(log.data[@"requesting"]);
    XCTAssertEqualObjects(log.data[@"requesting"][@"identifier"], @"com.apple.sandboxd");
    XCTAssertEqualObjects(log.data[@"requesting"][@"pid"], @"150");
    XCTAssertEqualObjects(log.data[@"requesting"][@"auid"], @"0");
    XCTAssertEqualObjects(log.data[@"requesting"][@"euid"], @"0");
    XCTAssertEqualObjects(log.data[@"requesting"][@"binary_path"], @"/usr/libexec/sandboxd");
}

- (void)testUnifiedLogReadAuthReqSubject {
    TCCLog* needle = [self helperUnifiedLogRead:@"AUTHREQ_SUBJECT"];
    
    XCTAssertNotNil(needle);
    XCTAssertEqualObjects(needle.type, @"AUTHREQ_SUBJECT");
    XCTAssertNotEqualObjects(needle.msgID, @"");
    
    XCTAssertNotNil(needle.data);
    XCTAssertNotEqualObjects(needle.data[@"subject"], @"");
}

- (void)testTCCLogParseAuthReqSubject {
    NSString* message = @"AUTHREQ_SUBJECT: msgID=150.33, subject=com.apple.Terminal,";

    TCCLog* log = [[TCCLog alloc] initFromString:message];

    XCTAssertNotNil(log);
    XCTAssertEqualObjects(log.msgID, @"150.33");
    XCTAssertEqualObjects(log.type, @"AUTHREQ_SUBJECT");
    
    XCTAssertNotNil(log.data);
    XCTAssertEqualObjects(log.data[@"subject"], @"com.apple.Terminal");
}

- (void)testUnifiedLogReadAuthReqResult {
    TCCLog* needle = [self helperUnifiedLogRead:@"AUTHREQ_RESULT"];
    
    XCTAssertNotNil(needle);
    XCTAssertEqualObjects(needle.type, @"AUTHREQ_RESULT");
    XCTAssertNotEqualObjects(needle.msgID, @"");
    
    XCTAssertNotNil(needle.data);
    XCTAssertNotEqualObjects(needle.data[@"authValue"], @"");
    XCTAssertNotEqualObjects(needle.data[@"authReason"], @"");
    XCTAssertNotEqualObjects(needle.data[@"authVersion"], @"");
    XCTAssertNotEqualObjects(needle.data[@"error"], @"");
}

- (void)testTCCLogParseAuthReqResult {
    NSString* message = @"AUTHREQ_RESULT: msgID=150.33, authValue=0, authReason=5, authVersion=1, error=(null),";

    TCCLog* log = [[TCCLog alloc] initFromString:message];

    XCTAssertNotNil(log);
    XCTAssertEqualObjects(log.msgID, @"150.33");
    XCTAssertEqualObjects(log.type, @"AUTHREQ_RESULT");
    
    XCTAssertNotNil(log.data);
    XCTAssertEqualObjects(log.data[@"authValue"], @"0");
    XCTAssertEqualObjects(log.data[@"authReason"], @"5");
    XCTAssertEqualObjects(log.data[@"authVersion"], @"1");
    XCTAssertEqualObjects(log.data[@"error"], @"(null)");
}

- (void)testUnifiedLogReadAuthReqPrompting {
    TCCLog* needle = [self helperUnifiedLogRead:@"AUTHREQ_PROMPTING" withCommand:@"ls ~/Library/Calendars" sleepFor:60];
    
    XCTAssertNotNil(needle);
    XCTAssertEqualObjects(needle.type, @"AUTHREQ_PROMPTING");
    XCTAssertNotEqualObjects(needle.msgID, @"");

    XCTAssertNotNil(needle.data);
    XCTAssertNotEqualObjects(needle.data[@"service"], @"");

    XCTAssertNotNil(needle.data[@"responsible"]);
    XCTAssertNotEqualObjects(needle.data[@"responsible"][@"identifier"], @"");
    XCTAssertNotEqualObjects(needle.data[@"responsible"][@"pid"], @"");
    XCTAssertNotEqualObjects(needle.data[@"responsible"][@"auid"], @"");
    XCTAssertNotEqualObjects(needle.data[@"responsible"][@"euid"], @"");
    XCTAssertNotEqualObjects(needle.data[@"responsible"][@"responsible_path"], @"");
    XCTAssertNotEqualObjects(needle.data[@"responsible"][@"binary_path"], @"");
    
    [self helperRunShellCommand:@"killall -9 UserNotificationCenter"];
    [self helperRunShellCommand:@"tccutil reset Calendar com.apple.dt.xcode"];
}

- (void)testTCCLogParseAuthReqPrompting {
    NSString* message = @"AUTHREQ_PROMPTING: msgID=150.34, service=kTCCServiceSystemPolicyDownloadsFolder, subject=Sub:{com.apple.Terminal}Resp:{<TCCDProcess: identifier=com.apple.Terminal, pid=436, auid=501, euid=501, responsible_path=/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal, binary_path=/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal>},";

    TCCLog* log = [[TCCLog alloc] initFromString:message];

    XCTAssertNotNil(log);
    XCTAssertEqualObjects(log.msgID, @"150.34");
    XCTAssertEqualObjects(log.type, @"AUTHREQ_PROMPTING");
    
    XCTAssertNotNil(log.data);
    XCTAssertEqualObjects(log.data[@"service"], @"kTCCServiceSystemPolicyDownloadsFolder");
    
    XCTAssertNotNil(log.data[@"responsible"]);
    XCTAssertEqualObjects(log.data[@"responsible"][@"identifier"], @"com.apple.Terminal");
    XCTAssertEqualObjects(log.data[@"responsible"][@"pid"], @"436");
    XCTAssertEqualObjects(log.data[@"responsible"][@"auid"], @"501");
    XCTAssertEqualObjects(log.data[@"responsible"][@"euid"], @"501");
    XCTAssertEqualObjects(log.data[@"responsible"][@"responsible_path"], @"/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal");
    XCTAssertEqualObjects(log.data[@"responsible"][@"binary_path"], @"/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal");
}


@end
