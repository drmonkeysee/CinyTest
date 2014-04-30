//
//  CTRunSuiteTests.m
//  CinyTest
//
//  Created by Brandon Stansbury on 4/29/14.
//  Copyright (c) 2014 Monkey Bits. All rights reserved.
//

#include "ciny.h"

static int passing_test_invocations;
static void passing_test(void *context)
{
    ++passing_test_invocations;
}

@interface CTRunSuiteTests : XCTestCase

@end

@implementation CTRunSuiteTests

- (void)setUp
{
    [super setUp];
    
    passing_test_invocations = 0;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_ctrunsuite_ReturnsZero_IfSuiteHasNullTestList
{
    struct ct_testsuite suite_to_run = ct_makesuite(NULL);
    
    size_t run_result = ct_runsuite(&suite_to_run);
    
    XCTAssertEqual(0, run_result);
}

- (void)test_ctrunsuite_InvokesPassingTests_IfValidTestcases
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(passing_test), ct_maketest(passing_test) };
    size_t expected_invocation_count = sizeof cases / sizeof cases[0];
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(expected_invocation_count, passing_test_invocations);
}

- (void)test_ctrunsuite_IgnoresTests_IfNullTestcase
{
    struct ct_testcase cases[] = { ct_maketest(passing_test), ct_maketest(NULL), ct_maketest(passing_test) };
    struct ct_testsuite suite = ct_makesuite(cases);
    
    size_t run_result = ct_runsuite(&suite);
    
    XCTAssertEqual(0, run_result);
    XCTAssertEqual(2, passing_test_invocations);
}

@end
