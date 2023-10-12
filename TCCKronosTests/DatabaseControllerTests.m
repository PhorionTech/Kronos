
//  DatabaseControllerTests.m
//  TCCKronosTests




#import <XCTest/XCTest.h>

#import "DatabaseController.h"
#import "TCCLog.h"
#import "Constants.h"

#define TEST_DB_NAME @"test.sqlite"

@interface DatabaseControllerTests : XCTestCase

@end

@implementation DatabaseControllerTests {
    DatabaseController* _db;
    NSFileManager* _fm;
}

- (void)setUp {
    NSError* error;

    _fm = [NSFileManager defaultManager];
    [_fm removeItemAtPath:[DATABASE_PATH stringByAppendingPathComponent:TEST_DB_NAME] error:&error];
    
    if (error) {
        NSLog(@"Failed to delete test db: %@", [error localizedDescription]);
    }
    
    _db = [[DatabaseController alloc] initWithDatabase:TEST_DB_NAME inDirectory:DATABASE_PATH];

}

- (void)tearDown {
    [_db close];
}

- (void)testDatabaseInit {
    XCTAssertNotNil(_db);
}

- (void)testDatabaseAccessWithRequestLog {
    NSString* message = @"REQUEST: tccd_uid=0, sender_pid=150, sender_uid=0, sender_auid=-1, function=TCCAccessRequest, msgID=150.33";
    
    TCCLog* log = [[TCCLog alloc] initFromString:message];
    
    XCTAssertTrue([_db writeTCCLogToDatabase:log]);
}

- (void)testDatabaseAccessWithAuthReqCtxLog {
    [self testDatabaseAccessWithRequestLog];
    
    NSString* message = @"AUTHREQ_CTX: msgID=150.33, function=TCCAccessRequest, service=kTCCServiceSystemPolicyAllFiles, preflight=yes, query=1,";

    TCCLog* log = [[TCCLog alloc] initFromString:message];
    
    XCTAssertTrue([_db writeTCCLogToDatabase:log]);
}

- (void)testDatabaseAccessWithAuthReqAttributionLog {
    [self testDatabaseAccessWithAuthReqCtxLog];
    
    NSString* message = @"AUTHREQ_ATTRIBUTION: msgID=150.33, attribution={responsible={<TCCDProcess: identifier=com.apple.Terminal, pid=436, auid=501, euid=501, responsible_path=/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal, binary_path=/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal>}, accessing={<TCCDProcess: identifier=com.apple.ls, pid=1253, auid=501, euid=501, binary_path=/bin/ls>}, requesting={<TCCDProcess: identifier=com.apple.sandboxd, pid=150, auid=0, euid=0, binary_path=/usr/libexec/sandboxd>}, },";

    TCCLog* log = [[TCCLog alloc] initFromString:message];
    
    XCTAssertTrue([_db writeTCCLogToDatabase:log]);
}

- (void)testDatabaseAccessWithAuthReqResultLog {
    [self testDatabaseAccessWithAuthReqAttributionLog];
    
    NSString* message = @"AUTHREQ_RESULT: msgID=150.33, authValue=0, authReason=5, authVersion=1, error=(null),";

    TCCLog* log = [[TCCLog alloc] initFromString:message];
    
    XCTAssertTrue([_db writeTCCLogToDatabase:log]);
}

- (void)testDatabaseAccessWithAuthReqPromptingLog {
    [self testDatabaseAccessWithAuthReqResultLog];
    
    NSString* message = @"AUTHREQ_PROMPTING: msgID=150.33, service=kTCCServiceSystemPolicyAllFiles, subject=Sub:{com.apple.Terminal}Resp:{<TCCDProcess: identifier=com.apple.Terminal, pid=436, auid=501, euid=501, responsible_path=/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal, binary_path=/System/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal>},";

    TCCLog* log = [[TCCLog alloc] initFromString:message];
    
    XCTAssertTrue([_db writeTCCLogToDatabase:log]);
}

@end
