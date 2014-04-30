//
//  CTRunSuiteTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 4/29/14.
//  Copyright (c) 2014 Monkey Bits. All rights reserved.
//

#import "ciny.h"

@interface CTRunSuiteTests : XCTestCase

@end

@implementation CTRunSuiteTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_ctrunsuite_ReturnsZero_IfSuiteHasNullTests
{
    struct ct_testsuite suite_to_run = ct_makesuite(NULL);
    
    size_t run_result = ct_runsuite(&suite_to_run);
    
    XCTAssertEqual(0, run_result);
}

@end
