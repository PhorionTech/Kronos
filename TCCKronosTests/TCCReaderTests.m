
//  TCCHelperTests.m
//  TCCKronosTests




#import <XCTest/XCTest.h>
#import <SystemConfiguration/SystemConfiguration.h>

#import "TCCHelper.h"

@interface TCCHelperTests : XCTestCase

@end

@implementation TCCHelperTests {
    TCCHelper* _tccHelper;
}

- (void)setUp {
    CFStringRef result;

    result = SCDynamicStoreCopyConsoleUser(nil, NULL, NULL);

    // If the current console user is "loginwindow", treat that as equivalent
    // to none.

    if ( (result != NULL) && CFEqual(result, CFSTR("loginwindow")) ) {
        CFRelease(result);
        result = NULL;
    }
    
    XCTAssertNotEqual(result, NULL);
    
    _tccHelper = [[TCCHelper alloc] initWithUser:CFBridgingRelease(result)];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testDatabaseSetup {
    XCTAssertNotNil(_tccHelper);
}

- (void)testDatabaseReadAll {
    XCTAssertTrue([[_tccHelper selectAll] count] > 0);
}


@end
