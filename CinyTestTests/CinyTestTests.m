//
//  CinyTestTests.m
//  CinyTestTests
//
//  Created by Brandon Stansbury on 4/12/14.
//  Copyright (c) 2014 Monkey Bits. All rights reserved.
//

#include "ciny.h"

void faketest(void *context)
{
    // do nothing
}

void fakesetup(void **context)
{
    // do nothing
}

void faketeardown(void **context)
{
    // do nothing
}

@interface CinyTestTests : XCTestCase

@end

@implementation CinyTestTests

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

- (void)test_ctmaketest_CreatesTestCase
{
    ct_test_function expected_function = faketest;
    
    ct_testcase testcase = ct_maketest(faketest);
    
    XCTAssertEqualObjects(@"faketest", [NSString stringWithUTF8String:testcase.name]);
    XCTAssertEqual(expected_function, testcase.test);
}

- (void)test_ctmaketestfull_CreatesTestCaseWithName
{
    ct_test_function expected_function = faketest;
    
    ct_testcase testcase = ct_maketest_full("fake name", expected_function);
    
    XCTAssertEqualObjects(@"fake name", [NSString stringWithUTF8String:testcase.name]);
    XCTAssertEqual(expected_function, testcase.test);
}

- (void)test_ctmaketestfull_CreatesTestCase_IfNullArguments
{
    ct_testcase testcase = ct_maketest_full(NULL, NULL);
    
    XCTAssertTrue(testcase.name == NULL, @"Expected NULL name");
    XCTAssertTrue(testcase.test == NULL, @"Expected NULL function");
}

- (void)test_ctmakesuitefull_CreatesTestSuiteWithArguments
{
    ct_testcase faketests[] = { ct_maketest_full("foo", NULL), ct_maketest_full("bar", NULL) };
    ct_testcase *expected_tests = faketests;
    size_t expected_count = 10;
    ct_setupteardown_function expected_setup = fakesetup;
    ct_setupteardown_function expected_teardown = faketeardown;
    
    ct_testsuite testsuite = ct_makesuite_full("fake suite", faketests, expected_count, expected_setup, expected_teardown);
    
    XCTAssertEqualObjects(@"fake suite", [NSString stringWithUTF8String:testsuite.name]);
    XCTAssertEqual(expected_tests, testsuite.tests);
    XCTAssertEqual(expected_count, testsuite.count);
    XCTAssertEqual(expected_setup, testsuite.setup);
    XCTAssertEqual(expected_teardown, testsuite.teardown);
}

- (void)test_ctmakesuitefull_CreatesTestSuite_IfNullArguments
{
    ct_testsuite testsuite = ct_makesuite_full(NULL, NULL, 0, NULL, NULL);
    
    XCTAssertTrue(testsuite.name == NULL, @"Expected NULL name.");
    XCTAssertTrue(testsuite.tests == NULL, @"Expected NULL tests.");
    XCTAssertEqual(0, testsuite.count);
    XCTAssertTrue(testsuite.setup == NULL, @"Expected NULL setup.");
    XCTAssertTrue(testsuite.teardown == NULL, @"Expected NULL teardown.");
}

@end
