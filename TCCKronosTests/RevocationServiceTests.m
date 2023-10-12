
//  RevocationServiceTests.m
//  TCCKronosTests




#import <XCTest/XCTest.h>
#import "DatabaseController.h"
#import "RevocationService.h"

@interface RevocationServiceTests : XCTestCase

@end

@implementation RevocationServiceTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    DatabaseController* db = [[DatabaseController alloc] init];
    RevocationService* revocationService = [[RevocationService alloc] initWithDatabase:db];
}
@end
